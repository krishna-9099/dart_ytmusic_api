import 'dart:async';

import 'decipherer.dart';

typedef Op = Map<String, dynamic>;

afterThrow(String s) {}

/// Prototype extractor for YouTube player JS signature transforms.
///
/// This intentionally implements a small, robust subset of common
/// transformation patterns found in player JS (swap, splice, reverse, slice)
/// and translates the sequence into an ordered list of operations. The
/// extractor is tolerant and will return an empty list if it cannot find a
/// viable transform.
class PlayerJsExtractor {
  /// Extract ordered operations from player JS text. Returns an empty list when
  /// no transform is detected.
  static List<Op> extractOps(String js) {
    final ops = <Op>[];

    // Helper to find a helper object's body by name (var/let/const or assignment)
    String? findHelperBody(String name) {
      final patterns = [
        RegExp(r"(?:var|let|const)\s+" + RegExp.escape(name) + r"\s*=\s*\{([\s\S]*?)\};", multiLine: true),
        RegExp(RegExp.escape(name) + r"\s*=\s*\{([\s\S]*?)\};", multiLine: true)
      ];
      for (final p in patterns) {
        final m = p.firstMatch(js);
        if (m != null) return m.group(1) ?? '';
      }
      return null;
    }

    // Infer op type from a method's body string
    String? inferOpFromMethodBody(String body) {
      if (body.contains('reverse')) return 'reverse';
      if (body.contains('splice')) return 'splice';
      if (body.contains('slice')) return 'slice';
      if (RegExp(r'var\s+\w+\s*=\s*\w+\[\s*0\s*\]').hasMatch(body) || (body.contains('a[0') && body.contains('a[b'))) return 'swap';
      return null;
    }

    // Find signature function by matching any function that returns <param>.join
    final sigRe = RegExp(r"function\s+([a-zA-Z0-9\$]+)\s*\(\s*([a-zA-Z0-9_\$]+)\s*\)\s*\{([\s\S]*?)return\s+\2\.join", multiLine: true);
    final altRe = RegExp(r"var\s+([a-zA-Z0-9\$]+)\s*=\s*function\s*\(\s*([a-zA-Z0-9_\$]+)\s*\)\s*\{([\s\S]*?)return\s+\2\.join", multiLine: true);

    Match? sigMatch = sigRe.firstMatch(js) ?? altRe.firstMatch(js);
    if (sigMatch == null) return ops;

    final paramName = sigMatch.group(2)!;
    final sigBody = sigMatch.group(3) ?? '';

    // Collect all helper-style calls and direct (param) calls in order of appearance
    final entries = <Map<String, dynamic>>[];

    // helper.method(param, arg?) matches
    final helperCallRe = RegExp(r"([a-zA-Z0-9\$]+)\.([a-zA-Z0-9\$]+)\s*\(\s*" + RegExp.escape(paramName) + r"(?:\s*,\s*([0-9]+))?\s*\)", multiLine: true);
    for (final m in helperCallRe.allMatches(sigBody)) {
      entries.add({
        'start': m.start,
        'type': 'helper',
        'obj': m.group(1),
        'method': m.group(2),
        'arg': m.group(3) != null ? int.parse(m.group(3)!) : null
      });
    }

    // direct param calls like a.reverse(), a.splice(0,2)
    final paramCallRe = RegExp(r"\b" + RegExp.escape(paramName) + r"\.([a-zA-Z0-9\$]+)\s*\(([^\)]*)\)", multiLine: true);
    for (final m in paramCallRe.allMatches(sigBody)) {
      final argText = m.group(2) ?? '';
      int? arg;
      // choose the last numeric token as likely the relevant arg
      final nums = RegExp(r"-?\d+").allMatches(argText).map((mm) => int.tryParse(mm.group(0)!)).where((x) => x != null).toList();
      if (nums.isNotEmpty) arg = nums.last as int?;
      entries.add({
        'start': m.start,
        'type': 'param',
        'method': m.group(1),
        'arg': arg
      });
    }

    // Sort by occurrence order
    entries.sort((a, b) => (a['start'] as int).compareTo(b['start'] as int));

    // Process entries and map to ops
    for (final e in entries) {
      if (e['type'] == 'param') {
        final method = e['method'] as String;
        final arg = e['arg'] as int?;
        if (method.contains('reverse')) {
          ops.add({'op': 'reverse'});
        } else if (method.contains('splice')) {
          ops.add({'op': 'splice', 'arg': arg ?? 0});
        } else if (method.contains('slice')) {
          ops.add({'op': 'slice', 'arg': arg ?? 0});
        } else {
          // unknown direct method - skip
        }
      } else if (e['type'] == 'helper') {
        final obj = e['obj'] as String;
        final method = e['method'] as String;
        final arg = e['arg'] as int?;

        final helperBody = findHelperBody(obj);
        String? opType;
        if (helperBody != null) {
          // find method body inside helper body
          final methodRe = RegExp(RegExp.escape(method) + r"\s*:\s*function\s*\([^\)]*\)\s*\{([\s\S]*?)\}", multiLine: true);
          final m = methodRe.firstMatch(helperBody);
          if (m != null) {
            opType = inferOpFromMethodBody(m.group(1) ?? '');
          } else {
            // try assignment style: obj.method=function(...) { ... }
            final assignRe = RegExp(RegExp.escape(obj) + r"\." + RegExp.escape(method) + r"\s*=\s*function\s*\([^\)]*\)\s*\{([\s\S]*?)\}", multiLine: true);
            final am = assignRe.firstMatch(js);
            if (am != null) opType = inferOpFromMethodBody(am.group(1) ?? '');
          }
        }

        if (opType == 'reverse') ops.add({'op': 'reverse'});
        else if (opType == 'splice' || opType == 'slice') ops.add({'op': opType, 'arg': arg ?? 0});
        else if (opType == 'swap') ops.add({'op': 'swap', 'arg': arg ?? 0});
        // unknown helper method -> skip
      }
    }

    return ops;
  }

  /// Create a DecipherFn from JS text by extracting ops and returning a function
  /// that applies them. Returns null when no viable transform is detected.
  static Future<DecipherFn?> buildDecipherFromPlayerJs(String js) async {
    final ops = extractOps(js);
    if (ops.isEmpty) return null;

    return (String s) async {
      final sb = s.split('');
      for (final o in ops) {
        final op = o['op'] as String;
        final arg = o['arg'] as int?;
        if (op == 'reverse') {
          sb.reversed.toList();
          // reversed returns an Iterable; reassign to list
          final r = sb.reversed.toList();
          sb.clear();
          sb.addAll(r);
        } else if (op == 'splice') {
          final n = arg ?? 0;
          if (n > 0) {
            if (n >= sb.length) {
              sb.clear();
            } else {
              // remove first n elements
              sb.removeRange(0, n);
            }
          }
        } else if (op == 'slice') {
          final n = arg ?? 0;
          if (n >= sb.length) {
            sb.clear();
          } else if (n > 0) {
            final sliced = sb.sublist(n);
            sb.clear();
            sb.addAll(sliced);
          }
        } else if (op == 'swap') {
          final n = arg ?? 0;
          if (sb.isNotEmpty) {
            final idx = n % sb.length;
            final tmp = sb[0];
            sb[0] = sb[idx];
            sb[idx] = tmp;
          }
        }
      }
      return sb.join('');
    };
  }

  /// Convenience: extract ops and register a decipher function into Decipherer.
  /// Returns true when a decipher function was registered.
  static Future<bool> registerDecipherIfFound(String js) async {
    final fn = await buildDecipherFromPlayerJs(js);
    if (fn != null) {
      Decipherer.register(fn);
      return true;
    }
    return false;
  }
}

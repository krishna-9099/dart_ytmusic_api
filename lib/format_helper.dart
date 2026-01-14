import 'dart:core';

import 'package:dart_ytmusic_api/types.dart';
import 'package:dart_ytmusic_api/decipher/decipherer.dart';

class FormatUrlResult {
  final String? url;
  final bool requiresDecipher;
  final Map<String, String>? cipherParams; // parsed signatureCipher fields
  final DateTime? expiresAt;

  FormatUrlResult(
      {this.url,
      this.requiresDecipher = false,
      this.cipherParams,
      this.expiresAt});

  @override
  String toString() =>
      'FormatUrlResult(url: ${url?.split('?').first}, requiresDecipher: $requiresDecipher, expiresAt: $expiresAt)';
}

class FormatHelper {
  // Decipher registration is delegated to the isolated Decipherer module.
  // Keep the FormatHelper API for backwards compatibility.
  static void registerDecipherer(Future<String> Function(String s)? fn) {
    Decipherer.register(fn);
  }

  /// Normalize format entry to accessible fields
  static Map<String, dynamic> _normalize(dynamic f) {
    if (f is Map<String, dynamic>) return f;
    return {};
  }

  /// Parse an URL's query and return a map
  static Map<String, String> _parseQuery(String query) {
    final out = <String, String>{};
    for (final part in query.split('&')) {
      final idx = part.indexOf('=');
      if (idx >= 0) {
        final k = Uri.decodeQueryComponent(part.substring(0, idx));
        final v = Uri.decodeQueryComponent(part.substring(idx + 1));
        out[k] = v;
      }
    }
    return out;
  }

  /// Try to parse expires param from a URL query
  static DateTime? _parseExpiryFromUrl(String url) {
    try {
      final u = Uri.parse(url);
      final exp = u.queryParameters['expire'] ?? u.queryParameters['exp'];
      if (exp != null) {
        final secs = int.tryParse(exp);
        if (secs != null) {
          return DateTime.fromMillisecondsSinceEpoch(secs * 1000);
        }
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    final s = v.toString();
    return int.tryParse(s);
  }

  /// Resolve a format object to a playable URL when possible.
  /// If the format contains a direct 'url' field, returns it. If it contains
  /// a `signatureCipher`/`cipher`, parse it and set requiresDecipher=true.
  static Future<FormatUrlResult> resolveFormatUrl(dynamic format) async {
    final f = _normalize(format);
    // direct url
    if (f['url'] is String) {
      final url = f['url'] as String;
      return FormatUrlResult(
          url: url,
          requiresDecipher: false,
          cipherParams: null,
          expiresAt: _parseExpiryFromUrl(url));
    }

    // signatureCipher or cipher
    final cipherRaw = f['signatureCipher'] ?? f['cipher'];
    if (cipherRaw is String) {
      // cipher is url-encoded string of key=value&...
      final parts = _parseQuery(cipherRaw);
      final parsed = <String, String>{};
      parsed.addAll(parts);

      // Some responses encode the entire string as a value of 'signatureCipher' that includes url=...
      // ensure 'url' is parsed as full URL
      if (parts.containsKey('url') && parts['url'] != null) {
        final url = parts['url']!;
        final expiresAt = _parseExpiryFromUrl(url);
        // If s is present, requires decipher
        final s = parts['s'];
        if (s != null) {
          try {
            final decoded = await Decipherer.tryDecipher(s);
            if (decoded != null) {
              final sp = parts['sp'] ?? 'sig';
              // Append deciphered signature
              final sep = url.contains('?') ? '&' : '?';
              final finalUrl = '$url$sep$sp=${Uri.encodeComponent(decoded)}';
              return FormatUrlResult(
                  url: finalUrl,
                  requiresDecipher: false,
                  cipherParams: parsed,
                  expiresAt: expiresAt);
            } else {
              // No decipherer registered / failed to decode => requires decipher
              return FormatUrlResult(
                  url: null,
                  requiresDecipher: true,
                  cipherParams: parsed,
                  expiresAt: expiresAt);
            }
          } catch (e) {
            // Decipher failed; fall back to requiresDecipher
            return FormatUrlResult(
                url: null,
                requiresDecipher: true,
                cipherParams: parsed,
                expiresAt: expiresAt);
          }
        }

        final requires = s != null;
        return FormatUrlResult(
            url: requires ? null : url,
            requiresDecipher: requires,
            cipherParams: parsed,
            expiresAt: expiresAt);
      }

      // If 'url' not present (rare), still return parsed cipher params
      return FormatUrlResult(
          url: null,
          requiresDecipher: true,
          cipherParams: parsed,
          expiresAt: null);
    }

    return FormatUrlResult(
        url: null,
        requiresDecipher: false,
        cipherParams: null,
        expiresAt: null);
  }

  /// Select best audio format from combined formats lists. Returns a FormatChoice
  /// which contains metadata and a resolved URL result (may require decipher).
  static Future<FormatChoice> selectBestAudioFormat(List<dynamic> formats,
      {List<String>? preferredMimeTypes,
      bool preferOpus = true,
      int? maxBitrate}) async {
    final normalized = formats
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();

    // Build candidates: prefer audio-only entries; fallback to video+audio
    List<Map<String, dynamic>> audioOnly = [];
    List<Map<String, dynamic>> mixed = [];

    for (final f in normalized) {
      final mime = f['mimeType'] as String? ?? f['mime'] as String? ?? '';
      if (mime.contains('audio/')) {
        audioOnly.add(f);
      } else {
        mixed.add(f);
      }
    }

    final candidates = audioOnly.isNotEmpty ? audioOnly : mixed;

    // Scoring function
    int score(Map<String, dynamic> f) {
      int s = 0;
      final mime = (f['mimeType'] ?? f['mime'] ?? '') as String;
      final codecs = (f['codecs'] ?? '') as String? ?? '';
      final bitrate = _toInt(f['bitrate'] ?? f['averageBitrate'] ?? 0) ?? 0;
      final audioQuality = (f['audioQuality'] ?? '') as String;

      // prefer opus
      if (preferOpus &&
          (codecContains(codecs, 'opus') || mime.contains('webm'))) {
        s += 1000;
      }
      // prefer higher audioQuality
      if (audioQuality.toLowerCase().contains('high')) {
        s += 800;
      } else if (audioQuality.toLowerCase().contains('medium')) {
        s += 400;
      }
      // prefer higher bitrate
      s += (bitrate ~/ 1000);

      // preferred mime types ordering
      if (preferredMimeTypes != null) {
        final idx = preferredMimeTypes.indexWhere((p) => mime.contains(p));
        if (idx >= 0) s += (100 - idx);
      }

      // penalize above maxBitrate
      if (maxBitrate != null && bitrate > maxBitrate) {
        s -= (bitrate - maxBitrate) ~/ 1000;
      }

      return s;
    }

    if (candidates.isEmpty) {
      return FormatChoice.empty();
    }

    candidates.sort((a, b) => score(b).compareTo(score(a)));
    final best = candidates.first;
    final urlResult = await resolveFormatUrl(best);

    return FormatChoice(
      url: urlResult.url,
      mimeType:
          (best['mimeType'] as String?) ?? (best['mime'] as String?) ?? '',
      bitrate: _toInt(best['bitrate'] ?? best['averageBitrate']),
      audioQuality: best['audioQuality'] as String?,
      itag: _toInt(best['itag']),
      approxDurationMs: _toInt(best['approxDurationMs']),
      requiresDecipher: urlResult.requiresDecipher,
      cipherParams: urlResult.cipherParams,
      expiresAt: urlResult.expiresAt,
      raw: best,
    );
  }

  static bool codecContains(String codecs, String needle) {
    return codecs.toLowerCase().contains(needle.toLowerCase());
  }
}

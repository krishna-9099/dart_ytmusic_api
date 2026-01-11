import 'dart:convert';
import 'dart:core';

import 'package:dart_ytmusic_api/types.dart';

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
      'FormatUrlResult(url: ${url != null ? url!.split('?').first : null}, requiresDecipher: $requiresDecipher, expiresAt: $expiresAt)';
}

class FormatHelper {
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
        if (secs != null)
          return DateTime.fromMillisecondsSinceEpoch(secs * 1000);
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  /// Resolve a format object to a playable URL when possible.
  /// If the format contains a direct 'url' field, returns it. If it contains
  /// a `signatureCipher`/`cipher`, parse it and set requiresDecipher=true.
  static FormatUrlResult resolveFormatUrl(dynamic format) {
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
        final requires = parts.containsKey('s');
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
  static FormatChoice selectBestAudioFormat(List<dynamic> formats,
      {List<String>? preferredMimeTypes,
      bool preferOpus = true,
      int? maxBitrate}) {
    final normalized = formats
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();

    // Build candidates: prefer audio-only entries; fallback to video+audio
    List<Map<String, dynamic>> audioOnly = [];
    List<Map<String, dynamic>> mixed = [];

    for (final f in normalized) {
      final mime = f['mimeType'] as String? ?? f['mime'] as String? ?? '';
      if (mime.contains('audio/'))
        audioOnly.add(f);
      else
        mixed.add(f);
    }

    final candidates = audioOnly.isNotEmpty ? audioOnly : mixed;

    // Scoring function
    int score(Map<String, dynamic> f) {
      int s = 0;
      final mime = (f['mimeType'] ?? f['mime'] ?? '') as String;
      final codecs = (f['codecs'] ?? '') as String? ?? '';
      final bitrate = (f['bitrate'] ?? f['averageBitrate'] ?? 0) as int;
      final audioQuality = (f['audioQuality'] ?? '') as String;

      // prefer opus
      if (preferOpus &&
          (codecContains(codecs, 'opus') || mime.contains('webm'))) s += 1000;
      // prefer higher audioQuality
      if (audioQuality.toLowerCase().contains('high'))
        s += 800;
      else if (audioQuality.toLowerCase().contains('medium')) s += 400;
      // prefer higher bitrate
      s += (bitrate ~/ 1000);

      // preferred mime types ordering
      if (preferredMimeTypes != null) {
        final idx = preferredMimeTypes.indexWhere((p) => mime.contains(p));
        if (idx >= 0) s += (100 - idx);
      }

      // penalize above maxBitrate
      if (maxBitrate != null && bitrate > maxBitrate)
        s -= (bitrate - maxBitrate) ~/ 1000;

      return s;
    }

    if (candidates.isEmpty) {
      return FormatChoice.empty();
    }

    candidates.sort((a, b) => score(b).compareTo(score(a)));
    final best = candidates.first;
    final urlResult = resolveFormatUrl(best);

    return FormatChoice(
      url: urlResult.url,
      mimeType:
          (best['mimeType'] as String?) ?? (best['mime'] as String?) ?? '',
      bitrate: (best['bitrate'] ?? best['averageBitrate']) as int?,
      audioQuality: best['audioQuality'] as String?,
      itag: best['itag'] as int?,
      approxDurationMs: best['approxDurationMs'] as int?,
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

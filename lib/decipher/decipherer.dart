/// Decipher module: centralizes registration and dispatching of player signature
/// decipher functions. This keeps all decipher-related logic isolated from the
/// rest of `lib/` for easier maintenance and future expansion (e.g. JS
/// extraction, automated fetchers, etc.).

typedef DecipherFn = Future<String> Function(String s);

class Decipherer {
  // Currently registered decipher function. Use [register] to set or unset.
  static DecipherFn? _fn;

  /// Register a decipher function, or pass `null` to unregister.
  static void register(DecipherFn? fn) {
    _fn = fn;
  }

  /// Try to run the registered decipher function on [s]. Returns the decoded
  /// signature or `null` when no decipherer is registered or if decoding fails.
  static Future<String?> tryDecipher(String s) async {
    final fn = _fn;
    if (fn == null) return null;
    try {
      final res = await fn(s);
      return res;
    } catch (_) {
      // On error, return null so callers can fall back to signalling
      // requiresDecipher=true rather than crash.
      return null;
    }
  }
}

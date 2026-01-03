import 'package:dart_ytmusic_api/utils/traverse.dart';

bool isTitle(dynamic data) {
  return traverseString(data, ["musicVideoType"])
          ?.startsWith("MUSIC_VIDEO_TYPE_") ??
      false;
}

/// Verifica se um objeto representa um artista.
bool isArtist(dynamic data) {
  final pageType = traverseString(data, ["pageType"]);
  return ["MUSIC_PAGE_TYPE_USER_CHANNEL", "MUSIC_PAGE_TYPE_ARTIST"]
      .contains(pageType);
}

/// Verifica se um objeto representa um álbum.
bool isAlbum(dynamic data) {
  return traverseString(data, ["pageType"]) == "MUSIC_PAGE_TYPE_ALBUM";
}

/// Verifica se um objeto representa uma duração.
bool isDuration(dynamic data) {
  final text = traverseString(data, ["text"]);
  return RegExp(r"(\d{1,2}:)?\d{1,2}:\d{1,2}").hasMatch(text ?? '');
}

/// Recursively strip any 'clickTrackingParams' keys from a Map or List
/// Returns a deep-copied structure with those keys removed.
dynamic stripClickTrackingParams(dynamic data) {
  if (data == null) return null;
  if (data is Map) {
    final Map<String, dynamic> out = {};
    data.forEach((key, value) {
      if (key == 'clickTrackingParams') return; // skip
      out[key] = stripClickTrackingParams(value);
    });
    return out;
  }
  if (data is List) {
    return data.map((e) => stripClickTrackingParams(e)).toList();
  }
  return data;
}

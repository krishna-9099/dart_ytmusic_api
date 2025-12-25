import 'package:dart_ytmusic_api/types.dart';
import 'package:dart_ytmusic_api/utils/filters.dart';
import 'package:dart_ytmusic_api/utils/traverse.dart';

class PlaylistParser {
  static PlaylistFull parse(dynamic data, String playlistId) {
    final artist = traverse(data, ["tabs", "straplineTextOne"]);

    return PlaylistFull(
      type: "PLAYLIST",
      playlistId: playlistId,
      name: traverseString(data, ["tabs", "title", "text"]) ?? '',
      artist: ArtistBasic(
        name: traverseString(artist, ["text"]) ?? '',
        artistId: traverseString(artist, ["browseId"]),
      ),
      videoCount: (() {
        try {
          final subtitleList =
              traverseList(data, ["tabs", "secondSubtitle", "text"]);
          if (subtitleList.isNotEmpty) {
            // Try to find a string that contains a number followed by "songs"
            for (final item in subtitleList) {
              if (item is String) {
                final match =
                    RegExp(r'(\d+(?:,\d+)*)\s+songs?').firstMatch(item);
                if (match != null) {
                  return int.tryParse(
                          match.group(1)?.replaceAll(',', '') ?? '0') ??
                      0;
                }
              }
            }
            // Fallback: try the original logic
            if (subtitleList.length >= 3) {
              final text = subtitleList.elementAt(2).toString();
              return int.tryParse(text.split(" ").first.replaceAll(",", "")) ??
                  0;
            }
          }
          return 0;
        } catch (e) {
          return 0;
        }
      })(),
      thumbnails: traverseList(data, ["tabs", "thumbnails"])
          .map((item) => ThumbnailFull.fromMap(item))
          .toList(),
    );
  }

  static PlaylistDetailed parseSearchResult(dynamic item) {
    final columns = traverseList(item, ["flexColumns", "runs"])
        .expand((e) => e is List ? e : [e])
        .toList();

    // No specific way to identify the title
    final title = columns[0];
    final artist = columns.firstWhere(
      isArtist,
      orElse: () => columns.length > 2
          ? columns[3]
          : AlbumBasic(
              albumId: '',
              name: '',
            ),
    );

    return PlaylistDetailed(
      type: "PLAYLIST",
      playlistId: traverseString(item, ["overlay", "playlistId"]) ?? '',
      name: traverseString(title, ["text"]) ?? '',
      artist: ArtistBasic(
        name: traverseString(artist, ["text"]) ?? '',
        artistId: traverseString(artist, ["browseId"]),
      ),
      thumbnails: traverseList(item, ["thumbnails"])
          .map((item) => ThumbnailFull.fromMap(item))
          .toList(),
    );
  }

  static PlaylistDetailed parseArtistFeaturedOn(
      dynamic item, ArtistBasic artistBasic) {
    return PlaylistDetailed(
      type: "PLAYLIST",
      playlistId:
          traverseString(item, ["navigationEndpoint", "browseId"]) ?? '',
      name: traverseString(item, ["runs", "text"]) ?? '',
      artist: artistBasic,
      thumbnails: traverseList(item, ["thumbnails"])
          .map((item) => ThumbnailFull.fromMap(item))
          .toList(),
    );
  }

  static PlaylistDetailed parseHomeSection(dynamic item) {
    final artist = traverse(item, ["subtitle", "runs"]);

    return PlaylistDetailed(
      type: "PLAYLIST",
      playlistId:
          traverseString(item, ["navigationEndpoint", "playlistId"]) ?? '',
      name: traverseString(item, ["runs", "text"]) ?? '',
      artist: ArtistBasic(
        name: traverseString(artist, ["text"]) ?? '',
        artistId: traverseString(artist, ["browseId"]),
      ),
      thumbnails: traverseList(item, ["thumbnails"])
          .map((item) => ThumbnailFull.fromMap(item))
          .toList(),
    );
  }
}

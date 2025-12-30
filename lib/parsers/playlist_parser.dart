import 'package:dart_ytmusic_api/types.dart';
import 'package:dart_ytmusic_api/utils/filters.dart';
import 'package:dart_ytmusic_api/utils/traverse.dart';

class PlaylistParser {
  static PlaylistFull parse(dynamic data, String playlistId) {
    // Try several common locations for the playlist author/owner.
    String? artistName = traverseString(
            data, ["tabs", "straplineTextOne", "text"]) ??
        traverseString(data, ["tabs", "straplineTextOne", "runs", "text"]) ??
        traverseString(data, [
          "header",
          "musicDetailHeaderRenderer",
          "bylineText",
          "runs",
          "text"
        ]) ??
        traverseString(data, [
          "header",
          "musicDetailHeaderRenderer",
          "subtitle",
          "runs",
          "text"
        ]) ??
        traverseString(data, ["metadata", "ownerText", "runs", "text"]) ??
        // Some playlist pages put the owner in a facepile under the playlist header.
        traverseString(data, [
          "contents",
          "twoColumnBrowseResultsRenderer",
          "secondaryContents",
          "sectionListRenderer",
          "contents",
          "musicPlaylistShelfRenderer",
          "facepile",
          "text",
          "content",
        ]) ??
        traverseString(data, [
          "contents",
          "twoColumnBrowseResultsRenderer",
          "tabs",
          "tabRenderer",
          "content",
          "sectionListRenderer",
          "contents",
          "musicResponsiveHeaderRenderer",
          "facepile",
          "text",
          "content",
        ]);

    String? artistId =
        traverseString(data, ["tabs", "straplineTextOne", "browseId"]) ??
            traverseString(
                data, ["tabs", "straplineTextOne", "runs", "browseId"]) ??
            traverseString(data, [
              "header",
              "musicDetailHeaderRenderer",
              "bylineText",
              "runs",
              "browseId"
            ]) ??
            traverseString(data, ["metadata", "ownerText", "runs", "browseId"]);

    // Try to find owner browseId from facepile on playlist header
    artistId ??= traverseString(data, [
      "contents",
      "twoColumnBrowseResultsRenderer",
      "secondaryContents",
      "sectionListRenderer",
      "contents",
      "musicPlaylistShelfRenderer",
      "facepile",
      "rendererContext",
      "commandContext",
      "onTap",
      "innertubeCommand",
      "browseEndpoint",
      "browseId",
    ]);

    artistId ??= traverseString(data, [
      "contents",
      "twoColumnBrowseResultsRenderer",
      "tabs",
      "tabRenderer",
      "content",
      "sectionListRenderer",
      "contents",
      "musicResponsiveHeaderRenderer",
      "facepile",
      "rendererContext",
      "commandContext",
      "onTap",
      "innertubeCommand",
      "browseEndpoint",
      "browseId",
    ]);

    return PlaylistFull(
      type: "PLAYLIST",
      playlistId: playlistId,
      name: traverseString(data, ["tabs", "title", "text"]) ?? '',
      artist: ArtistBasic(
        name: artistName ?? '',
        artistId: artistId,
      ),
      videoCount: (() {
        try {
          // Try to get video count from the playlist shelf
          final shelfContents = traverseList(data, [
            "contents",
            "twoColumnBrowseResultsRenderer",
            "secondaryContents",
            "sectionListRenderer",
            "contents",
            "musicPlaylistShelfRenderer",
            "contents"
          ]);
          final collapsedCount = traverseString(data, [
            "contents",
            "twoColumnBrowseResultsRenderer",
            "secondaryContents",
            "sectionListRenderer",
            "contents",
            "musicPlaylistShelfRenderer",
            "collapsedItemCount"
          ]);
          final visibleCount = shelfContents.length;
          final collapsed = int.tryParse(collapsedCount ?? '0') ?? 0;
          if (visibleCount > 0 || collapsed > 0) {
            return visibleCount + collapsed;
          }

          // Fallback to subtitle parsing
          final subtitleList = traverseList(data, [
            "contents",
            "twoColumnBrowseResultsRenderer",
            "tabs",
            "tabRenderer",
            "content",
            "sectionListRenderer",
            "contents",
            "musicResponsiveHeaderRenderer",
            "subtitle",
            "runs",
            "text"
          ]);
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
              final parsed =
                  int.tryParse(text.split(" ").first.replaceAll(",", ""));
              // Don't use the year as video count
              if (parsed != null && parsed > 1900 && parsed < 2100) {
                return 0; // Likely a year, not video count
              }
              return parsed ?? 0;
            }
          }
          return 0;
        } catch (e) {
          return 0;
        }
      })(),
      year: (() {
        try {
          final subtitleList = traverseList(data, [
            "contents",
            "twoColumnBrowseResultsRenderer",
            "tabs",
            "tabRenderer",
            "content",
            "sectionListRenderer",
            "contents",
            "musicResponsiveHeaderRenderer",
            "subtitle",
            "runs",
            "text"
          ]);
          if (subtitleList.isNotEmpty) {
            for (final item in subtitleList) {
              if (item is String) {
                final match = RegExp(r'(\d{4})').firstMatch(item);
                if (match != null) {
                  return int.tryParse(match.group(1)!) ?? DateTime.now().year;
                }
              }
            }
          }
          return null;
        } catch (e) {
          return null;
        }
      })(),
      viewCount: (() {
        try {
          final subtitleList = traverseList(data, [
            "contents",
            "twoColumnBrowseResultsRenderer",
            "tabs",
            "tabRenderer",
            "content",
            "sectionListRenderer",
            "contents",
            "musicResponsiveHeaderRenderer",
            "subtitle",
            "runs",
            "text"
          ]);
          if (subtitleList.isNotEmpty) {
            for (final item in subtitleList) {
              if (item is String) {
                final match =
                    RegExp(r'(\d+(?:,\d+)*)\s+views?').firstMatch(item);
                if (match != null) {
                  return int.tryParse(
                          match.group(1)?.replaceAll(',', '') ?? '0') ??
                      null;
                }
              }
            }
          }
          return null;
        } catch (e) {
          return null;
        }
      })(),
      thumbnails: traverseList(data, ["tabs", "thumbnails"])
          .map((item) => ThumbnailFull.fromMap(item))
          .toList(),
      backgroundThumbnails: traverseList(data, [
        "background",
        "musicThumbnailRenderer",
        "thumbnail",
        "thumbnails"
      ]).map((item) => ThumbnailFull.fromMap(item)).toList(),
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

  static List<PlaylistDetailed> parseRelatedPlaylists(
      dynamic continuationData) {
    final related = traverseList(continuationData, [
      'continuationContents',
      'sectionListContinuation',
      'contents',
      'musicCarouselShelfRenderer',
      'contents',
      'musicTwoRowItemRenderer'
    ]);

    return related.map((item) {
      final title = traverseString(item, ['title', 'runs', 'text']);
      final browseId = traverseString(
          item, ['navigationEndpoint', 'browseEndpoint', 'browseId']);
      final subtitle = traverseList(item, ['subtitle', 'runs']);
      String artistName = '';
      String? artistId;
      if (subtitle.length >= 3) {
        artistName = traverseString(subtitle[2], ['text']) ?? '';
        artistId = traverseString(
            subtitle[2], ['navigationEndpoint', 'browseEndpoint', 'browseId']);
      }
      final thumbnails = traverseList(item, [
        'thumbnailRenderer',
        'musicThumbnailRenderer',
        'thumbnail',
        'thumbnails'
      ]).map((t) => ThumbnailFull.fromMap(t)).toList();

      return PlaylistDetailed(
        type: 'PLAYLIST',
        playlistId: browseId ?? '',
        name: title ?? '',
        artist: ArtistBasic(name: artistName, artistId: artistId),
        thumbnails: thumbnails,
      );
    }).toList();
  }
}

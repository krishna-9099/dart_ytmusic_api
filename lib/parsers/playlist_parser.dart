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
    // Handle the musicTwoRowItemRenderer wrapper
    final actualItem =
        item is Map && item.containsKey('musicTwoRowItemRenderer')
            ? item['musicTwoRowItemRenderer']
            : item;

    String? playlistId;
    String? name;

    if (actualItem is Map) {
      final title = actualItem['title'];
      if (title is Map) {
        final runs = title['runs'];
        if (runs is List && runs.isNotEmpty) {
          final firstRun = runs[0];
          if (firstRun is Map) {
            name = firstRun['text'] as String?;
            final navEndpoint = firstRun['navigationEndpoint'];
            if (navEndpoint is Map) {
              final browseEndpoint = navEndpoint['browseEndpoint'];
              if (browseEndpoint is Map) {
                playlistId = browseEndpoint['browseId'] as String?;
              }
            }
          }
        }
      }

      // If not found in title, check navigationEndpoint at item level
      if (playlistId == null || playlistId!.isEmpty) {
        final navEndpoint = actualItem['navigationEndpoint'];
        if (navEndpoint is Map) {
          final browseEndpoint = navEndpoint['browseEndpoint'];
          if (browseEndpoint is Map) {
            playlistId = browseEndpoint['browseId'] as String?;
          }
        }
      }
    }

    // Fallback
    playlistId ??= '';
    name ??= '';

    // Try to parse views from subtitle runs (e.g., "9.7M views")
    String? views;
    final subtitleList = traverseList(actualItem, ["subtitle", "runs"])
        .map((r) => r is Map && r.containsKey('text') ? r['text'] : r)
        .toList();
    for (final element in subtitleList) {
      final text = element?.toString() ?? '';
      if (text.toLowerCase().contains('views')) {
        views = text;
        break;
      }
    }

    // Extract shuffle and mix navigation endpoints from menu if present
    Map<String, dynamic>? shuffleNav;
    Map<String, dynamic>? mixNav;
    final menuItems = actualItem is Map && actualItem['menu'] is Map
        ? (actualItem['menu']['menuRenderer']['items'] as List?)
        : null;
    if (menuItems != null) {
      for (final mi in menuItems) {
        if (mi is Map && mi['menuNavigationItemRenderer'] is Map) {
          final mr = mi['menuNavigationItemRenderer'] as Map;
          final iconType = mr['icon'] is Map ? mr['icon']['iconType'] : null;
          final nav = mr['navigationEndpoint'] as Map<String, dynamic>?;
          if (iconType == 'MUSIC_SHUFFLE' && nav != null) {
            shuffleNav = stripClickTrackingParams(nav) as Map<String, dynamic>?;
          }
          if (iconType == 'MIX' && nav != null) {
            mixNav = stripClickTrackingParams(nav) as Map<String, dynamic>?;
          }
        }
      }
    }

    return PlaylistDetailed(
      type: "PLAYLIST",
      playlistId: playlistId,
      name: name,
      artist: artistBasic,
      thumbnails: (traverseList(actualItem, ["thumbnail", "thumbnails"]) ??
              traverseList(actualItem, ["thumbnails"]))
          .map((item) => ThumbnailFull.fromMap(item))
          .toList(),
      views: views,
      shuffleNavigationEndpoint: shuffleNav,
      mixNavigationEndpoint: mixNav,
    );
  }

  static PlaylistDetailed parseHomeSection(dynamic item) {
    final artist = traverse(item, ["subtitle", "runs"]);

    // Try to extract views from subtitle runs
    String? views;
    final subtitleRuns = traverseList(item, ["subtitle", "runs"])
        .map((r) => r is Map && r.containsKey('text') ? r['text'] : r)
        .toList();
    for (final element in subtitleRuns) {
      final text = element?.toString() ?? '';
      if (text.toLowerCase().contains('views')) {
        views = text;
        break;
      }
    }

    // Extract shuffle/mix endpoints from menu
    Map<String, dynamic>? shuffleNav;
    Map<String, dynamic>? mixNav;
    final menuItems = item is Map && item['menu'] is Map
        ? (item['menu']['menuRenderer']['items'] as List?)
        : null;
    if (menuItems != null) {
      for (final mi in menuItems) {
        if (mi is Map && mi['menuNavigationItemRenderer'] is Map) {
          final mr = mi['menuNavigationItemRenderer'] as Map;
          final iconType = mr['icon'] is Map ? mr['icon']['iconType'] : null;
          final nav = mr['navigationEndpoint'] as Map<String, dynamic>?;
          if (iconType == 'MUSIC_SHUFFLE' && nav != null)
            shuffleNav = stripClickTrackingParams(nav) as Map<String, dynamic>?;
          if (iconType == 'MIX' && nav != null)
            mixNav = stripClickTrackingParams(nav) as Map<String, dynamic>?;
        }
      }
    }

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
      views: views,
      shuffleNavigationEndpoint: shuffleNav,
      mixNavigationEndpoint: mixNav,
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

      // Extract views if present in subtitle runs
      String? views;
      final subtitleRuns = traverseList(item, ['subtitle', 'runs'])
          .map((r) => r is Map && r.containsKey('text') ? r['text'] : r)
          .toList();
      for (final element in subtitleRuns) {
        final text = element?.toString() ?? '';
        if (text.toLowerCase().contains('views')) {
          views = text;
          break;
        }
      }

      return PlaylistDetailed(
        type: 'PLAYLIST',
        playlistId: browseId ?? '',
        name: title ?? '',
        artist: ArtistBasic(name: artistName, artistId: artistId),
        thumbnails: thumbnails,
        views: views,
      );
    }).toList();
  }
}

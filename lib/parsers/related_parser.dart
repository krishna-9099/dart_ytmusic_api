import 'package:dart_ytmusic_api/types.dart';
import 'package:dart_ytmusic_api/utils/traverse.dart';

class RelatedParser {
  static List<ThumbnailFull> _extractThumbnails(dynamic node) {
    final thumbs = <ThumbnailFull>[];

    // Candidate paths for thumbnails
    final candidates = [
      traverse(node,
          ['thumbnail', 'musicThumbnailRenderer', 'thumbnail', 'thumbnails']),
      traverse(node, ['thumbnail', 'thumbnails']),
      traverse(node, ['thumbnail', 'musicThumbnailRenderer', 'thumbnail']),
    ];

    for (final c in candidates) {
      if (c is List) {
        for (final t in c) {
          if (t is Map && t['url'] != null) {
            try {
              thumbs.add(ThumbnailFull.fromMap(Map<String, dynamic>.from(t)));
            } catch (e) {
              // ignore malformed thumbnail entry
            }
          }
        }
      }
    }

    // Sort by width descending so largest thumbnails come first
    thumbs.sort((a, b) => b.width.compareTo(a.width));
    return thumbs;
  }

  static String _getBestTextFromFlex(dynamic node, int index) {
    final texts = traverseList(node, [
      'flexColumns',
      'musicResponsiveListItemFlexColumnRenderer',
      'text',
      'runs',
      'text'
    ]).whereType<String>().toList();
    if (texts.isEmpty) return '';
    if (index < texts.length) return texts[index];
    return texts.first;
  }

  static String? _getArtistBrowseIdFromFlex(dynamic node) {
    final browseList = traverseList(node, [
      'flexColumns',
      'musicResponsiveListItemFlexColumnRenderer',
      'text',
      'runs',
      'navigationEndpoint',
      'browseEndpoint',
      'browseId'
    ]);
    if (browseList.isNotEmpty && browseList.first is String)
      return browseList.first as String;
    return null;
  }

  /// Parse a browse response (Related tab) and return a canonical list of RelatedItem
  static List<RelatedItem> parseRelatedBrowse(dynamic data) {
    final items = <RelatedItem>[];

    // Responsive list items (usually songs)
    final responsiveList =
        traverseList(data, ["musicResponsiveListItemRenderer"]);
    for (final node in responsiveList) {
      if (node is Map) {
        final renderer = node.containsKey('musicResponsiveListItemRenderer')
            ? node['musicResponsiveListItemRenderer']
            : node;
        if (renderer is Map) {
          final title = _getBestTextFromFlex(renderer, 0);
          final artist = _getBestTextFromFlex(renderer, 1);

          // videoId from play button overlay or text navigation endpoint
          final videoIdCandidate = traverse(renderer, [
            'overlay',
            'musicItemThumbnailOverlayRenderer',
            'content',
            'musicPlayButtonRenderer',
            'playNavigationEndpoint',
            'watchEndpoint',
            'videoId'
          ]);
          String? vid = videoIdCandidate is String ? videoIdCandidate : null;
          if (vid == null) {
            final watchList = traverseList(renderer, [
              'flexColumns',
              'musicResponsiveListItemFlexColumnRenderer',
              'text',
              'runs',
              'navigationEndpoint',
              'watchEndpoint',
              'videoId'
            ]);
            if (watchList.isNotEmpty && watchList.first is String)
              vid = watchList.first as String;
          }

          final thumbs = _extractThumbnails(renderer);

          items.add(RelatedItem(
            kind: 'song',
            id: vid ?? '',
            title: title,
            subtitle: artist,
            thumbnails: thumbs,
            raw: renderer as Map<String, dynamic>?,
          ));
        }
      }
    }

    // Two-row items (albums/playlists/artists)
    final twoRow = traverseList(data, ["musicTwoRowItemRenderer"]);
    for (final node in twoRow) {
      if (node is Map) {
        final renderer = node.containsKey('musicTwoRowItemRenderer')
            ? node['musicTwoRowItemRenderer']
            : node;
        if (renderer is Map) {
          final title =
              traverseString(renderer, ["title", "runs", "text"]) ?? '';
          final subtitle =
              traverseString(renderer, ["subtitle", "runs", "text"]) ?? '';

          // Browse id may be under different navigation endpoints
          dynamic browseId = traverse(renderer, [
            'title',
            'runs',
            'navigationEndpoint',
            'browseEndpoint',
            'browseId'
          ]);
          if (browseId == null)
            browseId = traverse(
                renderer, ['navigationEndpoint', 'browseEndpoint', 'browseId']);

          String id = '';
          String kind = 'unknown';
          if (browseId is String) {
            id = browseId;
            if (id.startsWith('UC'))
              kind = 'artist';
            else if (id.startsWith('PL') ||
                id.startsWith('OL') ||
                id.startsWith('RD'))
              kind = 'playlist';
            else
              kind = 'album_or_playlist';
          }

          final thumbs = _extractThumbnails(renderer);

          items.add(RelatedItem(
            kind: kind,
            id: id,
            title: title,
            subtitle: subtitle,
            thumbnails: thumbs,
            raw: renderer as Map<String, dynamic>?,
          ));
        }
      }
    }

    // Also support carousels (they typically contain responsive items)
    final carousels = traverseList(data, ['musicCarouselShelfRenderer']);
    for (final c in carousels) {
      final children = traverseList(c, ['musicResponsiveListItemRenderer']);
      for (final node in children) {
        if (node is Map) {
          final renderer = node.containsKey('musicResponsiveListItemRenderer')
              ? node['musicResponsiveListItemRenderer']
              : node;
          if (renderer is Map) {
            final title = traverseString(renderer, [
                  'flexColumns',
                  'musicResponsiveListItemFlexColumnRenderer',
                  'text',
                  'runs',
                  'text'
                ]) ??
                '';
            final artist = _getBestTextFromFlex(renderer, 1);
            final videoIdCandidate = traverse(renderer, [
              'overlay',
              'musicItemThumbnailOverlayRenderer',
              'content',
              'musicPlayButtonRenderer',
              'playNavigationEndpoint',
              'watchEndpoint',
              'videoId'
            ]);
            String? vid = videoIdCandidate is String ? videoIdCandidate : null;
            final thumbs = _extractThumbnails(renderer);

            items.add(RelatedItem(
              kind: 'song',
              id: vid ?? '',
              title: title,
              subtitle: artist,
              thumbnails: thumbs,
              raw: renderer as Map<String, dynamic>?,
            ));
          }
        }
      }
    }

    // Playlist panel video renderer (common in watch/queue contexts)
    final panelVideos = traverseList(data, ['playlistPanelVideoRenderer']);
    for (final pv in panelVideos) {
      final renderer =
          (pv is Map && pv.containsKey('playlistPanelVideoRenderer'))
              ? pv['playlistPanelVideoRenderer']
              : pv;
      if (renderer is Map) {
        final videoId = renderer['videoId'] as String? ?? '';
        final title = traverseString(renderer, ['title', 'runs', 'text']) ?? '';
        final artist =
            traverseString(renderer, ['longBylineText', 'runs', 'text']) ?? '';
        final thumbs = _extractThumbnails(renderer);
        items.add(RelatedItem(
          kind: 'song',
          id: videoId,
          title: title,
          subtitle: artist,
          thumbnails: thumbs,
          raw: renderer as Map<String, dynamic>?,
        ));
      }
    }

    // Music shelf renderer: contains a contents list of items
    final shelves = traverseList(data, ['musicShelfRenderer']);
    for (final shelf in shelves) {
      if (shelf is Map) {
        // Re-run parsing on the shelf - it may contain responsive or two-row items
        final nested = parseRelatedBrowse(shelf);
        items.addAll(nested);
      }
    }

    // Deduplicate items (preserve order)
    final seen = <String>{};
    final uniqueItems = <RelatedItem>[];
    for (final it in items) {
      final key = '${it.kind}:${it.id}:${it.title}';
      if (!seen.contains(key)) {
        seen.add(key);
        uniqueItems.add(it);
      }
    }

    return uniqueItems;
  }
}

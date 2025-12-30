import 'package:dart_ytmusic_api/yt_music.dart';
import 'package:dart_ytmusic_api/types.dart';
import 'package:dart_ytmusic_api/utils/traverse.dart';
import 'package:dart_ytmusic_api/parsers/video_parser.dart';

/// Thin adapter around `dart_ytmusic_api` to be used by Muse services.
class YtMusicAdapter {
  final YTMusic ytmusic;

  YtMusicAdapter({YTMusic? client}) : ytmusic = client ?? YTMusic();

  Future<void> initialize() => ytmusic.initialize();

  Future<PlaylistFull> fetchPlaylistMeta(String playlistId) async {
    return await ytmusic.getPlaylist(playlistId);
  }

  Future<List<VideoDetailed>> fetchPlaylistVideos(String playlistId) async {
    return await ytmusic.getPlaylistVideos(playlistId);
  }

  /// Page result that includes parsed items and an optional continuation token.
  Future<PlaylistVideosPage> fetchPlaylistVideosPage(String playlistId,
      {String? continuationToken}) async {
    var pid = playlistId;
    if (pid.startsWith('PL') || pid.startsWith('RD')) pid = 'VL$pid';

    dynamic data;
    if (continuationToken == null) {
      data = await ytmusic.constructRequest('browse', body: {'browseId': pid});
    } else {
      data = await ytmusic.constructRequest('browse',
          query: {'continuation': continuationToken});
    }

    // Try both initial page renderer and continuation page renderer
    var items = traverseList(data,
        ['musicPlaylistShelfRenderer', 'musicResponsiveListItemRenderer']);
    if (items.isEmpty) {
      items = traverseList(data, ['musicResponsiveListItemRenderer']);
    }

    final parsed = items
        .map((it) => VideoParser.parsePlaylistVideo(it))
        .whereType<VideoDetailed>()
        .toList();

    dynamic cont = traverse(data, ['continuation']);
    if (cont is List) {
      cont = cont.isNotEmpty ? cont[0] : null;
    }

    String? next;
    if (cont is String) {
      next = cont;
    } else if (cont is Map && cont.containsKey('token')) {
      next = cont['token']?.toString();
    }

    return PlaylistVideosPage(items: parsed, continuationToken: next);
  }

  /// Convenience method to fetch all pages (be careful with very large playlists).
  Future<List<VideoDetailed>> fetchAllPlaylistVideos(String playlistId,
      {int? pageLimit}) async {
    final all = <VideoDetailed>[];
    String? cont;
    var pages = 0;
    do {
      final page =
          await fetchPlaylistVideosPage(playlistId, continuationToken: cont);
      all.addAll(page.items);
      cont = page.continuationToken;
      pages++;
      if (pageLimit != null && pages >= pageLimit) break;
    } while (cont != null);
    return all;
  }
}

class PlaylistVideosPage {
  final List<VideoDetailed> items;
  final String? continuationToken;

  PlaylistVideosPage({required this.items, required this.continuationToken});
}

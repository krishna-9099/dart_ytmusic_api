import 'package:dart_ytmusic_api/parsers/album_parser.dart';
import 'package:dart_ytmusic_api/parsers/playlist_parser.dart';
import 'package:dart_ytmusic_api/parsers/song_parser.dart';
import 'package:dart_ytmusic_api/parsers/video_parser.dart';
import 'package:dart_ytmusic_api/types.dart';
import 'package:dart_ytmusic_api/utils/filters.dart';
import 'package:dart_ytmusic_api/utils/filters.dart';
import 'package:dart_ytmusic_api/utils/traverse.dart';

class ArtistParser {
  static ArtistFull parse(dynamic data, String artistId) {
    final artistBasic = ArtistBasic(
      artistId: artistId,
      name: traverseString(data, ["header", "title", "text"]) ?? '',
    );
    // Extract top songs title
    final topSongsTitle =
        traverseString(data, ['musicShelfRenderer', 'title', 'runs', 'text']) ??
            traverseString(data, ['musicShelfRenderer', 'title', 'text']);

    // Read carousels and map them to the right section by title heuristics
    final carousels = traverseList(data, ['musicCarouselShelfRenderer']);

    String? topAlbumsTitle;
    String? topSinglesTitle;
    String? topVideosTitle;
    String? featuredOnTitle;
    String? playlistsByArtistTitle;
    String? similarArtistsTitle;

    List<AlbumDetailed> topAlbums = [];
    List<AlbumDetailed> topSingles = [];
    List<VideoDetailed> topVideos = [];
    List<PlaylistDetailed> featuredOn = [];
    List<PlaylistDetailed> playlistsByArtist = [];
    List<ArtistDetailed> similarArtists = [];
    // Collect headings locally for output; not stored on ArtistFull anymore
    List<String> headings = [];

    final Map<String, dynamic> sectionShowAllNavs = {};
    for (final el in carousels) {
      final title = (el is Map &&
                  el['header'] is Map &&
                  el['header']['musicCarouselShelfBasicHeaderRenderer']
                      is Map &&
                  el['header']['musicCarouselShelfBasicHeaderRenderer']['title']
                      is Map &&
                  el['header']['musicCarouselShelfBasicHeaderRenderer']['title']
                      ['runs'] is List &&
                  (el['header']['musicCarouselShelfBasicHeaderRenderer']
                          ['title']['runs'] as List)
                      .isNotEmpty &&
                  (el['header']['musicCarouselShelfBasicHeaderRenderer']
                      ['title']['runs'] as List)[0] is Map
              ? (el['header']['musicCarouselShelfBasicHeaderRenderer']['title']
                  ['runs'] as List)[0]['text'] as String?
              : null) ??
          traverseString(el, ['title', 'runs', 'text']) ??
          traverseString(el, ['title', 'text']) ??
          '';

      final contents = (el is Map && el['contents'] is List)
          ? (el['contents'] as List<dynamic>)
          : <dynamic>[];

      // Try to extract a "more" / "show all" endpoint for this section (if present)
      try {
        // Possible locations include header.moreContentButton, bottomEndpoint, or a footer endpoint
        final possiblePaths = [
          [
            "header",
            "musicCarouselShelfBasicHeaderRenderer",
            "moreContentButton",
            "buttonRenderer",
            "navigationEndpoint"
          ],
          [
            "header",
            "moreContentButton",
            "buttonRenderer",
            "navigationEndpoint"
          ],
          ["bottomEndpoint"],
          ["musicShelfRenderer", "bottomEndpoint"],
          ["footer", "musicCarouselShelfBasicFooterRenderer", "endpoint"],
        ];
        Map? rawEndpoint;
        for (final p in possiblePaths) {
          final v = traverse(el, p);
          if (v is Map) {
            rawEndpoint = v.cast<String, dynamic>();
            break;
          }
        }
        if (rawEndpoint != null && title.isNotEmpty) {
          var sanitized =
              stripClickTrackingParams(rawEndpoint) as Map<String, dynamic>?;
          if (sanitized != null && sanitized['browseEndpoint'] is Map) {
            (sanitized['browseEndpoint'] as Map)
                .remove('browseEndpointContextSupportedConfigs');
          }
          sectionShowAllNavs[title] = sanitized;
        }
      } catch (e) {
        // Defensive: ignore extraction errors for this optional field
      }

      final tl = title.toLowerCase();

      if (tl.contains('album')) {
        topAlbumsTitle ??= title;
        headings.add(title);
        final parsed = contents
            .map((item) => AlbumParser.parseArtistTopAlbum(item, artistBasic))
            .whereType<AlbumDetailed>()
            .where((a) => a.albumId.isNotEmpty)
            .toList();
        topAlbums = [...topAlbums, ...parsed];
        continue;
      }

      if (tl.contains('single') || tl.contains('ep')) {
        topSinglesTitle ??= title;
        headings.add(title);
        final parsed = contents
            .map((item) => AlbumParser.parseArtistTopAlbum(item, artistBasic))
            .whereType<AlbumDetailed>()
            .where((a) => a.albumId.isNotEmpty && a.albumId.startsWith('M'))
            .toList();
        topSingles = [...topSingles, ...parsed];
        continue;
      }

      if (tl.contains('video')) {
        topVideosTitle ??= title;
        headings.add(title);
        final parsed = contents
            .map((item) => VideoParser.parseArtistTopVideo(item, artistBasic))
            .whereType<VideoDetailed>()
            .toList();
        topVideos = [...topVideos, ...parsed];
        continue;
      }

      if (tl.contains('feature') ||
          tl.contains('appears') ||
          tl.contains('live')) {
        featuredOnTitle ??= title;
        headings.add(title);
        final parsed = contents
            .map((item) =>
                PlaylistParser.parseArtistFeaturedOn(item, artistBasic))
            .whereType<PlaylistDetailed>()
            .where((p) =>
                p.playlistId.isNotEmpty && !p.playlistId.startsWith('UC'))
            .toList();
        featuredOn = [...featuredOn, ...parsed];
        continue;
      }

      if (tl.contains('playlist') && tl.contains('by')) {
        playlistsByArtistTitle ??= title;
        headings.add(title);
        final parsed = contents
            .map((item) =>
                PlaylistParser.parseArtistFeaturedOn(item, artistBasic))
            .whereType<PlaylistDetailed>()
            .where((p) =>
                p.playlistId.isNotEmpty && !p.playlistId.startsWith('UC'))
            .toList();
        playlistsByArtist = [...playlistsByArtist, ...parsed];
        continue;
      }

      if (tl.contains('similar') ||
          tl.contains('you might') ||
          tl.contains('also like')) {
        similarArtistsTitle ??= title;
        headings.add(title);
        final parsed = (contents)
            .map((item) => parseSimilarArtists(item))
            .whereType<ArtistDetailed>()
            .toList();
        similarArtists = [...similarArtists, ...parsed];
        continue;
      }

      // Fallback heuristics: try to detect by parsing results
      // Try albums
      final maybeAlbums = contents
          .map((item) => AlbumParser.parseArtistTopAlbum(item, artistBasic))
          .whereType<AlbumDetailed>()
          .where((a) => a.albumId.isNotEmpty)
          .toList();
      if (maybeAlbums.isNotEmpty) {
        topAlbumsTitle ??= title;
        headings.add(title);
        topAlbums = [...topAlbums, ...maybeAlbums];
        continue;
      }

      // Try playlists
      final maybePlaylists = contents
          .map(
              (item) => PlaylistParser.parseArtistFeaturedOn(item, artistBasic))
          .whereType<PlaylistDetailed>()
          .where(
              (p) => p.playlistId.isNotEmpty && !p.playlistId.startsWith('UC'))
          .toList();
      if (maybePlaylists.isNotEmpty) {
        featuredOnTitle ??= title;
        headings.add(title);
        featuredOn = [...featuredOn, ...maybePlaylists];
        continue;
      }

      // Try videos
      final maybeVideos = contents
          .map((item) => VideoParser.parseArtistTopVideo(item, artistBasic))
          .whereType<VideoDetailed>()
          .toList();
      if (maybeVideos.isNotEmpty) {
        topVideosTitle ??= title;
        headings.add(title);
        topVideos = [...topVideos, ...maybeVideos];
        continue;
      }
    }

    if (topSongsTitle != null) headings.add(topSongsTitle);

    final about = traverseString(data, ["description", "text"]);
    final subtitle =
        traverseString(data, ["header", "subtitle", "runs", "text"]);
    // Prefer explicit monthlyListenerCount if present, otherwise fallback to header subtitle
    final monthlyListenerCount = traverseString(
            data, ["header", "monthlyListenerCount", "runs", "text"]) ??
        subtitle;
    // Extract subscriber count if present
    final subscriberCount = traverseString(data, [
      "header",
      "musicImmersiveHeaderRenderer",
      "subscriptionButton",
      "subscribeButtonRenderer",
      "subscriberCountText",
      "runs",
      "text"
    ]);

    // Extract artist-level shuffle and mix navigation endpoints from header
    Map<String, dynamic>? artistShuffleNav;
    Map<String, dynamic>? artistMixNav;
    Map<String, dynamic>? topSongsShowAllNav;
    final header = data is Map && data['header'] is Map ? data['header'] : null;
    if (header is Map && header['musicImmersiveHeaderRenderer'] is Map) {
      final hr = header['musicImmersiveHeaderRenderer'] as Map;
      final playButtonNav = hr['playButton'] is Map &&
              hr['playButton']['buttonRenderer'] is Map
          ? (hr['playButton']['buttonRenderer'] as Map)['navigationEndpoint']
              as Map<String, dynamic>?
          : null;
      final startRadioNav = hr['startRadioButton'] is Map &&
              hr['startRadioButton']['buttonRenderer'] is Map
          ? (hr['startRadioButton']['buttonRenderer']
              as Map)['navigationEndpoint'] as Map<String, dynamic>?
          : null;
      artistShuffleNav =
          stripClickTrackingParams(playButtonNav) as Map<String, dynamic>?;
      artistMixNav =
          stripClickTrackingParams(startRadioNav) as Map<String, dynamic>?;

      // Extract "Show all" bottomEndpoint from musicShelfRenderer if present
      topSongsShowAllNav =
          (traverse(data, ["musicShelfRenderer", "bottomEndpoint"]) as Map?)
              ?.cast<String, dynamic>();
      if (topSongsShowAllNav != null) {
        topSongsShowAllNav = stripClickTrackingParams(topSongsShowAllNav)
            as Map<String, dynamic>?;
        // Simplify: remove nested browseEndpointContextSupportedConfigs to keep output compact
        if (topSongsShowAllNav != null &&
            topSongsShowAllNav['browseEndpoint'] is Map) {
          (topSongsShowAllNav['browseEndpoint'] as Map)
              .remove('browseEndpointContextSupportedConfigs');
        }
      }
    }

    return ArtistFull(
      name: artistBasic.name,
      type: "ARTIST",
      artistId: artistId,
      thumbnails: traverseList(data, ["header", "thumbnails"])
          .map((item) => ThumbnailFull.fromMap(item))
          .toList(),
      topSongsTitle: topSongsTitle,
      subtitle: subtitle,
      monthlyListenerCount: monthlyListenerCount,
      subscriberCount: subscriberCount,
      shuffleNavigationEndpoint: artistShuffleNav,
      mixNavigationEndpoint: artistMixNav,
      topSongsShowAllNavigationEndpoint: topSongsShowAllNav,
      sectionShowAllNavigationEndpoints:
          sectionShowAllNavs.isNotEmpty ? sectionShowAllNavs : null,
      topSongs: traverseList(data, ["musicShelfRenderer", "contents"])
          .map((item) => SongParser.parseArtistTopSong(item, artistBasic))
          .toList(),
      topAlbumsTitle: topAlbumsTitle,
      topAlbums: topAlbums,
      topSinglesTitle: topSinglesTitle,
      topSingles: topSingles,
      topVideosTitle: topVideosTitle,
      topVideos: topVideos,
      featuredOnTitle: featuredOnTitle,
      featuredOn: featuredOn,
      playlistsByArtistTitle: playlistsByArtistTitle,
      playlistsByArtist: playlistsByArtist,
      similarArtistsTitle: similarArtistsTitle,
      similarArtists: similarArtists,
      about: about,
    );
  }

  static ArtistDetailed parseSearchResult(dynamic item) {
    final columns = traverseList(item, ["flexColumns", "runs"])
        .expand((e) => e is List ? e : [e])
        .toList();

    // No specific way to identify the title
    final title = columns[0];

    return ArtistDetailed(
      type: "ARTIST",
      artistId: traverseString(item, ["browseId"]) ?? '',
      name: traverseString(title, ["text"]) ?? '',
      thumbnails: traverseList(item, ["thumbnails"])
          .map((item) => ThumbnailFull.fromMap(item))
          .toList(),
    );
  }

  static ArtistDetailed parseSimilarArtists(dynamic item) {
    final subtitle = traverseString(item, ["subtitle", "runs", "text"]);

    return ArtistDetailed(
      type: "ARTIST",
      artistId: traverseString(item, ["browseId"]) ?? '',
      name: traverseString(item, ["runs", "text"]) ?? '',
      thumbnails: traverseList(item, ["thumbnails"])
          .map((item) => ThumbnailFull.fromMap(item))
          .toList(),
      subtitle: subtitle,
    );
  }
}

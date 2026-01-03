import 'package:dart_ytmusic_api/parsers/album_parser.dart';
import 'package:dart_ytmusic_api/parsers/playlist_parser.dart';
import 'package:dart_ytmusic_api/parsers/song_parser.dart';
import 'package:dart_ytmusic_api/parsers/video_parser.dart';
import 'package:dart_ytmusic_api/types.dart';
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
    String? similarArtistsTitle;

    List<AlbumDetailed> topAlbums = [];
    List<AlbumDetailed> topSingles = [];
    List<VideoDetailed> topVideos = [];
    List<PlaylistDetailed> featuredOn = [];
    List<ArtistDetailed> similarArtists = [];

    for (final el in carousels) {
      final title = traverseString(el, ['title', 'runs', 'text']) ??
          traverseString(el, ['title', 'text']) ??
          '';

      final contents = (el is Map && el['contents'] is List)
          ? (el['contents'] as List<dynamic>)
          : <dynamic>[];

      final tl = title.toLowerCase();

      if (tl.contains('album')) {
        topAlbumsTitle ??= title;
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

      if (tl.contains('similar') ||
          tl.contains('you might') ||
          tl.contains('also like')) {
        similarArtistsTitle ??= title;
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
        topVideos = [...topVideos, ...maybeVideos];
        continue;
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
      topSongs: traverseList(data, ["musicShelfRenderer", "contents"])
          .map((item) => SongParser.parseArtistTopSong(item, artistBasic))
          .toList(),
      topAlbumsTitle: topAlbumsTitle,
      topAlbums: (traverseList(data, ["musicCarouselShelfRenderer"]).isEmpty
              ? <AlbumDetailed>[]
              : (traverseList(data, ["musicCarouselShelfRenderer"])
                          .elementAt(0)?['contents'] as List<dynamic>?)
                      ?.map((item) =>
                          AlbumParser.parseArtistTopAlbum(item, artistBasic))
                      .toList() ??
                  <AlbumDetailed>[])
          .where((album) => album.albumId.isNotEmpty)
          .toList(),
      topSinglesTitle: topSinglesTitle,
      topSingles: (traverseList(data, ["musicCarouselShelfRenderer"]).length < 2
              ? <AlbumDetailed>[]
              : (traverseList(data, ["musicCarouselShelfRenderer"])
                          .elementAt(1)?['contents'] as List<dynamic>?)
                      ?.map((item) =>
                          AlbumParser.parseArtistTopAlbum(item, artistBasic))
                      .toList() ??
                  <AlbumDetailed>[])
          .where((single) =>
              single.albumId.isNotEmpty && single.albumId.startsWith('M'))
          .toList(),
      topVideosTitle: topVideosTitle,
      topVideos: traverseList(data, ["musicCarouselShelfRenderer"]).length < 3
          ? <VideoDetailed>[]
          : (traverseList(data, ["musicCarouselShelfRenderer"])
                      .elementAt(2)?['contents'] as List<dynamic>?)
                  ?.map((item) =>
                      VideoParser.parseArtistTopVideo(item, artistBasic))
                  .toList() ??
              <VideoDetailed>[],
      featuredOnTitle: featuredOnTitle,
      featuredOn: traverseList(data, ["musicCarouselShelfRenderer"]).length < 4
          ? <PlaylistDetailed>[]
          : (traverseList(data, ["musicCarouselShelfRenderer"])
                      .elementAt(3)?['contents'] as List<dynamic>?)
                  ?.map((item) =>
                      PlaylistParser.parseArtistFeaturedOn(item, artistBasic))
                  .where((playlist) =>
                      playlist.playlistId.isNotEmpty &&
                      !playlist.playlistId
                          .startsWith('UC')) // Filter out channel IDs
                  .toList() ??
              <PlaylistDetailed>[],
      similarArtistsTitle: similarArtistsTitle,
      similarArtists:
          traverseList(data, ["musicCarouselShelfRenderer"]).length < 5
              ? <ArtistDetailed>[]
              : (traverseList(data, ["musicCarouselShelfRenderer"])
                          .elementAt(4)?['contents'] as List<dynamic>?)
                      ?.map((item) => parseSimilarArtists(item))
                      .toList() ??
                  <ArtistDetailed>[],
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
    return ArtistDetailed(
      type: "ARTIST",
      artistId: traverseString(item, ["browseId"]) ?? '',
      name: traverseString(item, ["runs", "text"]) ?? '',
      thumbnails: traverseList(item, ["thumbnails"])
          .map((item) => ThumbnailFull.fromMap(item))
          .toList(),
    );
  }
}

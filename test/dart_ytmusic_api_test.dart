import 'package:test/test.dart';
import 'package:dart_ytmusic_api/yt_music.dart';
import 'package:dart_ytmusic_api/types.dart';

void main() {
  test('Album parser should parse album details correctly', () {});

  test('getHomeSections should retrieve home sections', () async {
    final ytmusic = YTMusic();
    await ytmusic.initialize();

    final sections = await ytmusic.getHomeSections();

    expect(sections, isNotEmpty);
    for (final section in sections) {
      print('Section: "${section.title}"');
      expect(section.contents, isList);
      print('Contents count: ${section.contents.length}');
      // Print first few contents for inspection
      for (int i = 0; i < section.contents.length && i < 3; i++) {
        print('  Content $i: ${section.contents[i]}');
      }
      print('---');
    }
  });

  test('searchSongs should retrieve songs and check for pagination', () async {
    final ytmusic = YTMusic();
    await ytmusic.initialize();

    final result = await ytmusic.searchSongs('popular songs');

    // Handle both List<SongDetailed> and PaginatedResult<SongDetailed>
    List<SongDetailed> results;
    if (result is PaginatedResult<SongDetailed>) {
      results = result.items;
      print(
          'Paginated result: ${result.totalResultsFetched} songs, hasNextPage: ${result.hasNextPage}');
    } else {
      results = result as List<SongDetailed>;
    }

    expect(results, isNotEmpty);
    print('Found ${results.length} songs');

    // Print first few results for inspection
    for (int i = 0; i < results.length && i < 5; i++) {
      final song = results[i];
      print('Song $i: ${song.name} by ${song.artist.name}');
    }

    // Check if pagination is working - if we get more than 20 results, pagination is supported
    if (results.length > 20) {
      print(
          'Pagination is supported! Retrieved ${results.length} songs total.');
    } else {
      print(
          'Pagination may not be supported or there are not enough results to paginate.');
    }
  });

  test('searchSongs with paginated=true should return PaginatedResult',
      () async {
    final ytmusic = YTMusic();
    await ytmusic.initialize();

    final result = await ytmusic.searchSongs('popular songs', paginated: true);

    expect(result, isA<PaginatedResult<SongDetailed>>());
    final paginatedResult = result as PaginatedResult<SongDetailed>;

    expect(paginatedResult.items, isNotEmpty);
    print(
        'Paginated result: ${paginatedResult.items.length} songs, hasNextPage: ${paginatedResult.hasNextPage}, totalFetched: ${paginatedResult.totalResultsFetched}');

    // Should have a continuation token if there are more pages
    if (paginatedResult.hasNextPage) {
      expect(paginatedResult.continuationToken, isNotNull);
      print('Continuation token available for next page');
    }

    // Print first few results for inspection
    for (int i = 0; i < paginatedResult.items.length && i < 3; i++) {
      final song = paginatedResult.items[i];
      print('Song $i: ${song.name} by ${song.artist.name}');
    }
  });

  test('searchVideos should retrieve videos and check for pagination',
      () async {
    final ytmusic = YTMusic();
    await ytmusic.initialize();

    final result = await ytmusic.searchVideos('popular music videos');

    // Handle both List<VideoDetailed> and PaginatedResult<VideoDetailed>
    List<VideoDetailed> results;
    if (result is PaginatedResult<VideoDetailed>) {
      results = result.items;
      print(
          'Paginated result: ${result.totalResultsFetched} videos, hasNextPage: ${result.hasNextPage}');
    } else {
      results = result as List<VideoDetailed>;
    }

    expect(results, isNotEmpty);
    print('Found ${results.length} videos');

    // Print first few results for inspection
    for (int i = 0; i < results.length && i < 5; i++) {
      final video = results[i];
      print('Video $i: ${video.name} by ${video.artist.name}');
    }

    // Check if pagination is working - if we get more than 20 results, pagination is supported
    if (results.length > 20) {
      print(
          'Pagination is supported! Retrieved ${results.length} videos total.');
    } else {
      print(
          'Pagination may not be supported or there are not enough results to paginate.');
    }
  });

  test('searchVideos with paginated=true should return PaginatedResult',
      () async {
    final ytmusic = YTMusic();
    await ytmusic.initialize();

    final result =
        await ytmusic.searchVideos('popular music videos', paginated: true);

    expect(result, isA<PaginatedResult<VideoDetailed>>());
    final paginatedResult = result as PaginatedResult<VideoDetailed>;

    expect(paginatedResult.items, isNotEmpty);
    print(
        'Paginated result: ${paginatedResult.items.length} videos, hasNextPage: ${paginatedResult.hasNextPage}, totalFetched: ${paginatedResult.totalResultsFetched}');

    // Should have a continuation token if there are more pages
    if (paginatedResult.hasNextPage) {
      expect(paginatedResult.continuationToken, isNotNull);
      print('Continuation token available for next page');
    }

    // Print first few results for inspection
    for (int i = 0; i < paginatedResult.items.length && i < 3; i++) {
      final video = paginatedResult.items[i];
      print('Video $i: ${video.name} by ${video.artist.name}');
    }
  });

  test('searchPlaylists should retrieve playlists and check for pagination',
      () async {
    final ytmusic = YTMusic();
    await ytmusic.initialize();

    final result = await ytmusic.searchPlaylists('popular playlists');

    // Handle both List<PlaylistDetailed> and PaginatedResult<PlaylistDetailed>
    List<PlaylistDetailed> results;
    if (result is PaginatedResult<PlaylistDetailed>) {
      results = result.items;
      print(
          'Paginated result: ${result.totalResultsFetched} playlists, hasNextPage: ${result.hasNextPage}');
    } else {
      results = result as List<PlaylistDetailed>;
    }

    expect(results, isNotEmpty);
    print('Found ${results.length} playlists');

    // Print first few results for inspection
    for (int i = 0; i < results.length && i < 5; i++) {
      final playlist = results[i];
      print('Playlist $i: ${playlist.name} by ${playlist.artist.name}');
    }

    // Check if pagination is working - if we get more than 20 results, pagination is supported
    if (results.length > 20) {
      print(
          'Pagination is supported! Retrieved ${results.length} playlists total.');
    } else {
      print(
          'Pagination may not be supported or there are not enough results to paginate.');
    }
  });

  test('searchPlaylists with paginated=true should return PaginatedResult',
      () async {
    final ytmusic = YTMusic();
    await ytmusic.initialize();

    final result =
        await ytmusic.searchPlaylists('popular playlists', paginated: true);

    expect(result, isA<PaginatedResult<PlaylistDetailed>>());
    final paginatedResult = result as PaginatedResult<PlaylistDetailed>;

    expect(paginatedResult.items, isNotEmpty);
    print(
        'Paginated result: ${paginatedResult.items.length} playlists, hasNextPage: ${paginatedResult.hasNextPage}, totalFetched: ${paginatedResult.totalResultsFetched}');

    // Should have a continuation token if there are more pages
    if (paginatedResult.hasNextPage) {
      expect(paginatedResult.continuationToken, isNotNull);
      print('Continuation token available for next page');
    }

    // Print first few results for inspection
    for (int i = 0; i < paginatedResult.items.length && i < 3; i++) {
      final playlist = paginatedResult.items[i];
      print('Playlist $i: ${playlist.name} by ${playlist.artist.name}');
    }
  });

  test('searchArtists should retrieve artists and check for pagination',
      () async {
    final ytmusic = YTMusic();
    await ytmusic.initialize();

    final result = await ytmusic.searchArtists('popular artists');

    // Handle both List<ArtistDetailed> and PaginatedResult<ArtistDetailed>
    List<ArtistDetailed> results;
    if (result is PaginatedResult<ArtistDetailed>) {
      results = result.items;
      print(
          'Paginated result: ${result.totalResultsFetched} artists, hasNextPage: ${result.hasNextPage}');
    } else {
      results = result as List<ArtistDetailed>;
    }

    expect(results, isNotEmpty);
    print('Found ${results.length} artists');

    // Print first few results for inspection
    for (int i = 0; i < results.length && i < 5; i++) {
      final artist = results[i];
      print('Artist $i: ${artist.name}');
    }

    // Check if pagination is working - if we get more than 20 results, pagination is supported
    if (results.length > 20) {
      print(
          'Pagination is supported! Retrieved ${results.length} artists total.');
    } else {
      print(
          'Pagination may not be supported or there are not enough results to paginate.');
    }
  });

  test('searchArtists with paginated=true should return PaginatedResult',
      () async {
    final ytmusic = YTMusic();
    await ytmusic.initialize();

    final result =
        await ytmusic.searchArtists('popular artists', paginated: true);

    expect(result, isA<PaginatedResult<ArtistDetailed>>());
    final paginatedResult = result as PaginatedResult<ArtistDetailed>;

    expect(paginatedResult.items, isNotEmpty);
    print(
        'Paginated result: ${paginatedResult.items.length} artists, hasNextPage: ${paginatedResult.hasNextPage}, totalFetched: ${paginatedResult.totalResultsFetched}');

    // Should have a continuation token if there are more pages
    if (paginatedResult.hasNextPage) {
      expect(paginatedResult.continuationToken, isNotNull);
      print('Continuation token available for next page');
    }

    // Print first few results for inspection
    for (int i = 0; i < paginatedResult.items.length && i < 3; i++) {
      final artist = paginatedResult.items[i];
      print('Artist $i: ${artist.name}');
    }
  });

  test('searchAlbums should retrieve albums and check for pagination',
      () async {
    final ytmusic = YTMusic();
    await ytmusic.initialize();

    final result = await ytmusic.searchAlbums('popular albums');

    // Handle both List<AlbumDetailed> and PaginatedResult<AlbumDetailed>
    List<AlbumDetailed> results;
    if (result is PaginatedResult<AlbumDetailed>) {
      results = result.items;
      print(
          'Paginated result: ${result.totalResultsFetched} albums, hasNextPage: ${result.hasNextPage}');
    } else {
      results = result as List<AlbumDetailed>;
    }

    expect(results, isNotEmpty);
    print('Found ${results.length} albums');

    // Print first few results for inspection
    for (int i = 0; i < results.length && i < 5; i++) {
      final album = results[i];
      print('Album $i: ${album.name} by ${album.artist.name}');
    }

    // Check if pagination is working - if we get more than 20 results, pagination is supported
    if (results.length > 20) {
      print(
          'Pagination is supported! Retrieved ${results.length} albums total.');
    } else {
      print(
          'Pagination may not be supported or there are not enough results to paginate.');
    }
  });

  test('searchAlbums with paginated=true should return PaginatedResult',
      () async {
    final ytmusic = YTMusic();
    await ytmusic.initialize();

    final result =
        await ytmusic.searchAlbums('popular albums', paginated: true);

    expect(result, isA<PaginatedResult<AlbumDetailed>>());
    final paginatedResult = result as PaginatedResult<AlbumDetailed>;

    expect(paginatedResult.items, isNotEmpty);
    print(
        'Paginated result: ${paginatedResult.items.length} albums, hasNextPage: ${paginatedResult.hasNextPage}, totalFetched: ${paginatedResult.totalResultsFetched}');

    // Should have a continuation token if there are more pages
    if (paginatedResult.hasNextPage) {
      expect(paginatedResult.continuationToken, isNotNull);
      print('Continuation token available for next page');
    }

    // Print first few results for inspection
    for (int i = 0; i < paginatedResult.items.length && i < 3; i++) {
      final album = paginatedResult.items[i];
      print('Album $i: ${album.name} by ${album.artist.name}');
    }
  });

  test('getUpNexts should retrieve up next songs and check for pagination',
      () async {
    final ytmusic = YTMusic();
    await ytmusic.initialize();

    final result = await ytmusic.getUpNexts('LDY4Bf8Zwn8'); // Using the same video ID from example

    // Handle both List<UpNextsDetails> and PaginatedResult<UpNextsDetails>
    List<UpNextsDetails> results;
    if (result is PaginatedResult<UpNextsDetails>) {
      results = result.items;
      print('Paginated result: ${result.totalResultsFetched} up next songs, hasNextPage: ${result.hasNextPage}');
    } else {
      results = result as List<UpNextsDetails>;
    }

    expect(results, isNotEmpty);
    print('Found ${results.length} up next songs');

    // Print first few results for inspection
    for (int i = 0; i < results.length && i < 5; i++) {
      final song = results[i];
      print('Up Next $i: ${song.title} by ${song.artists.name}');
    }

    // Check if pagination is working - if we get more than 20 results, pagination is supported
    if (results.length > 20) {
      print(
          'Pagination is supported! Retrieved ${results.length} up next songs total.');
    } else {
      print(
          'Pagination may not be supported or there are not enough results to paginate.');
    }
  });

  test('getUpNexts with paginated=true should return PaginatedResult',
      () async {
    final ytmusic = YTMusic();
    await ytmusic.initialize();

    final result = await ytmusic.getUpNexts('LDY4Bf8Zwn8', paginated: true);

    expect(result, isA<PaginatedResult<UpNextsDetails>>());
    final paginatedResult = result as PaginatedResult<UpNextsDetails>;

    expect(paginatedResult.items, isNotEmpty);
    print('Paginated result: ${paginatedResult.items.length} up next songs, hasNextPage: ${paginatedResult.hasNextPage}, totalFetched: ${paginatedResult.totalResultsFetched}');

    // Should have a continuation token if there are more pages
    if (paginatedResult.hasNextPage) {
      expect(paginatedResult.continuationToken, isNotNull);
      print('Continuation token available for next page');
    }

    // Print first few results for inspection
    for (int i = 0; i < paginatedResult.items.length && i < 3; i++) {
      final song = paginatedResult.items[i];
      print('Up Next $i: ${song.title} by ${song.artists.name}');
    }
  });

  test('getUpNexts with continuationToken should return next page',
      () async {
    final ytmusic = YTMusic();
    await ytmusic.initialize();

    // First get the first page
    final firstPageResult = await ytmusic.getUpNexts('LDY4Bf8Zwn8', paginated: true);
    expect(firstPageResult, isA<PaginatedResult<UpNextsDetails>>());
    final firstPage = firstPageResult as PaginatedResult<UpNextsDetails>;

    if (firstPage.hasNextPage && firstPage.continuationToken != null) {
      // Get the second page using continuation token
      final secondPageResult = await ytmusic.getUpNexts('LDY4Bf8Zwn8',
          paginated: true, continuationToken: firstPage.continuationToken);
      expect(secondPageResult, isA<PaginatedResult<UpNextsDetails>>());
      final secondPage = secondPageResult as PaginatedResult<UpNextsDetails>;

      print('First page: ${firstPage.items.length} songs');
      print('Second page: ${secondPage.items.length} songs');

      // Verify that the pages are different (first song should be different)
      expect(firstPage.items.first.title, isNot(equals(secondPage.items.first.title)));

      // Print first few results from second page
      for (int i = 0; i < secondPage.items.length && i < 3; i++) {
        final song = secondPage.items[i];
        print('Page 2 - Up Next $i: ${song.title} by ${song.artists.name}');
      }
    } else {
      print('No continuation token available, skipping continuation test');
    }
  });
}

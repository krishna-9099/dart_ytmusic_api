import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:test/test.dart';
import 'package:dart_ytmusic_api/yt_music.dart';
import 'package:dart_ytmusic_api/types.dart';
import 'package:dart_ytmusic_api/utils/filters.dart';

void main() {
  // test('Album parser should parse album details correctly', () async {
  //   final ytmusic = YTMusic();
  //   await ytmusic.initialize();

  //   // Search for albums and pick the first result to inspect
  //   final searchResult = await ytmusic.searchAlbums('Abbey Road');

  //   List<AlbumDetailed> albums;
  //   if (searchResult is PaginatedResult<AlbumDetailed>) {
  //     albums = searchResult.items;
  //   } else {
  //     albums = searchResult as List<AlbumDetailed>;
  //   }

  //   expect(albums, isNotEmpty,
  //       reason: 'Expected at least one album from search');
  //   final brief = albums.first;
  //   print(
  //       'Album found: ${brief.name} by ${brief.artist.name} (id: ${brief.albumId})');

  //   // Fetch full album details and validate shape
  //   final full = await ytmusic.getAlbum(brief.albumId);
  //   expect(full, isA<AlbumFull>());
  //   expect(full.name, isNotEmpty);
  //   expect(full.artist.name, isNotEmpty);
  //   expect(full.thumbnails, isNotEmpty);
  //   expect(full.songs, isNotEmpty, reason: 'Album should contain songs');

  //   // Inspect first few songs for fields the UI will need
  //   for (final s in full.songs.take(5)) {
  //     print('Song: ${s.name} by ${s.artist.name}');
  //     expect(s.name, isNotEmpty);
  //     expect(s.artist.name, isNotEmpty);
  //     expect(s.thumbnails, isNotEmpty);
  //   }
  // });

  // test('getHomeSections should retrieve home sections', () async {
  //   final ytmusic = YTMusic();
  //   await ytmusic.initialize();

  //   final sections = await ytmusic.getHomeSections();

  //   expect(sections, isNotEmpty);
  //   for (final section in sections) {
  //     print('Section: "${section.title}"');
  //     expect(section.contents, isList);
  //     print('Contents count: ${section.contents.length}');
  //     // Print first few contents for inspection
  //     for (int i = 0; i < section.contents.length && i < 3; i++) {
  //       print('  Content $i: ${section.contents[i]}');
  //     }
  //     print('---');
  //   }
  // });

  // test('searchSongs should retrieve songs and check for pagination', () async {
  //   final ytmusic = YTMusic();
  //   await ytmusic.initialize();

  //   final result = await ytmusic.searchSongs('popular songs');

  //   // Handle both List<SongDetailed> and PaginatedResult<SongDetailed>
  //   List<SongDetailed> results;
  //   if (result is PaginatedResult<SongDetailed>) {
  //     results = result.items;
  //     print(
  //         'Paginated result: ${result.totalResultsFetched} songs, hasNextPage: ${result.hasNextPage}');
  //   } else {
  //     results = result as List<SongDetailed>;
  //   }

  //   expect(results, isNotEmpty);
  //   print('Found ${results.length} songs');

  //   // Print first few results for inspection
  //   for (int i = 0; i < results.length && i < 5; i++) {
  //     final song = results[i];
  //     print('Song $i: ${song.name} by ${song.artist.name}');
  //   }

  //   // Check if pagination is working - if we get more than 20 results, pagination is supported
  //   if (results.length > 20) {
  //     print(
  //         'Pagination is supported! Retrieved ${results.length} songs total.');
  //   } else {
  //     print(
  //         'Pagination may not be supported or there are not enough results to paginate.');
  //   }
  // });

  // test('searchSongs with paginated=true should return PaginatedResult',
  //     () async {
  //   final ytmusic = YTMusic();
  //   await ytmusic.initialize();

  //   final result = await ytmusic.searchSongs('popular songs', paginated: true);

  //   expect(result, isA<PaginatedResult<SongDetailed>>());
  //   final paginatedResult = result as PaginatedResult<SongDetailed>;

  //   expect(paginatedResult.items, isNotEmpty);
  //   print(
  //       'Paginated result: ${paginatedResult.items.length} songs, hasNextPage: ${paginatedResult.hasNextPage}, totalFetched: ${paginatedResult.totalResultsFetched}');

  //   // Should have a continuation token if there are more pages
  //   if (paginatedResult.hasNextPage) {
  //     expect(paginatedResult.continuationToken, isNotNull);
  //     print('Continuation token available for next page');
  //   }

  //   // Print first few results for inspection
  //   for (int i = 0; i < paginatedResult.items.length && i < 3; i++) {
  //     final song = paginatedResult.items[i];
  //     print('Song $i: ${song.name} by ${song.artist.name}');
  //   }
  // });

  // test('searchVideos should retrieve videos and check for pagination',
  //     () async {
  //   final ytmusic = YTMusic();
  //   await ytmusic.initialize();

  //   final result = await ytmusic.searchVideos('popular music videos');

  //   // Handle both List<VideoDetailed> and PaginatedResult<VideoDetailed>
  //   List<VideoDetailed> results;
  //   if (result is PaginatedResult<VideoDetailed>) {
  //     results = result.items;
  //     print(
  //         'Paginated result: ${result.totalResultsFetched} videos, hasNextPage: ${result.hasNextPage}');
  //   } else {
  //     results = result as List<VideoDetailed>;
  //   }

  //   expect(results, isNotEmpty);
  //   print('Found ${results.length} videos');

  //   // Print first few results for inspection
  //   for (int i = 0; i < results.length && i < 5; i++) {
  //     final video = results[i];
  //     print('Video $i: ${video.name} by ${video.artist.name}');
  //   }

  //   // Check if pagination is working - if we get more than 20 results, pagination is supported
  //   if (results.length > 20) {
  //     print(
  //         'Pagination is supported! Retrieved ${results.length} videos total.');
  //   } else {
  //     print(
  //         'Pagination may not be supported or there are not enough results to paginate.');
  //   }
  // });

  // test('searchVideos with paginated=true should return PaginatedResult',
  //     () async {
  //   final ytmusic = YTMusic();
  //   await ytmusic.initialize();

  //   final result =
  //       await ytmusic.searchVideos('popular music videos', paginated: true);

  //   expect(result, isA<PaginatedResult<VideoDetailed>>());
  //   final paginatedResult = result as PaginatedResult<VideoDetailed>;

  //   expect(paginatedResult.items, isNotEmpty);
  //   print(
  //       'Paginated result: ${paginatedResult.items.length} videos, hasNextPage: ${paginatedResult.hasNextPage}, totalFetched: ${paginatedResult.totalResultsFetched}');

  //   // Should have a continuation token if there are more pages
  //   if (paginatedResult.hasNextPage) {
  //     expect(paginatedResult.continuationToken, isNotNull);
  //     print('Continuation token available for next page');
  //   }

  //   // Print first few results for inspection
  //   for (int i = 0; i < paginatedResult.items.length && i < 3; i++) {
  //     final video = paginatedResult.items[i];
  //     print('Video $i: ${video.name} by ${video.artist.name}');
  //   }
  // });

  // test('searchPlaylists should retrieve playlists and check for pagination',
  //     () async {
  //   final ytmusic = YTMusic();
  //   await ytmusic.initialize();

  //   final result = await ytmusic.searchPlaylists('popular playlists');

  //   // Handle both List<PlaylistDetailed> and PaginatedResult<PlaylistDetailed>
  //   List<PlaylistDetailed> results;
  //   if (result is PaginatedResult<PlaylistDetailed>) {
  //     results = result.items;
  //     print(
  //         'Paginated result: ${result.totalResultsFetched} playlists, hasNextPage: ${result.hasNextPage}');
  //   } else {
  //     results = result as List<PlaylistDetailed>;
  //   }

  //   expect(results, isNotEmpty);
  //   print('Found ${results.length} playlists');

  //   // Print first few results for inspection
  //   for (int i = 0; i < results.length && i < 5; i++) {
  //     final playlist = results[i];
  //     print('Playlist $i: ${playlist.name} by ${playlist.artist.name}');
  //   }

  //   // Check if pagination is working - if we get more than 20 results, pagination is supported
  //   if (results.length > 20) {
  //     print(
  //         'Pagination is supported! Retrieved ${results.length} playlists total.');
  //   } else {
  //     print(
  //         'Pagination may not be supported or there are not enough results to paginate.');
  //   }
  // });

  // test('searchPlaylists with paginated=true should return PaginatedResult',
  //     () async {
  //   final ytmusic = YTMusic();
  //   await ytmusic.initialize();

  //   final result =
  //       await ytmusic.searchPlaylists('popular playlists', paginated: true);

  //   expect(result, isA<PaginatedResult<PlaylistDetailed>>());
  //   final paginatedResult = result as PaginatedResult<PlaylistDetailed>;

  //   expect(paginatedResult.items, isNotEmpty);
  //   print(
  //       'Paginated result: ${paginatedResult.items.length} playlists, hasNextPage: ${paginatedResult.hasNextPage}, totalFetched: ${paginatedResult.totalResultsFetched}');

  //   // Should have a continuation token if there are more pages
  //   if (paginatedResult.hasNextPage) {
  //     expect(paginatedResult.continuationToken, isNotNull);
  //     print('Continuation token available for next page');
  //   }

  //   // Print first few results for inspection
  //   for (int i = 0; i < paginatedResult.items.length && i < 3; i++) {
  //     final playlist = paginatedResult.items[i];
  //     print('Playlist $i: ${playlist.name} by ${playlist.artist.name}');
  //   }
  // });

  // test('searchArtists should retrieve artists and check for pagination',
  //     () async {
  //   final ytmusic = YTMusic();
  //   await ytmusic.initialize();

  //   final result = await ytmusic.searchArtists('popular artists');

  //   // Handle both List<ArtistDetailed> and PaginatedResult<ArtistDetailed>
  //   List<ArtistDetailed> results;
  //   if (result is PaginatedResult<ArtistDetailed>) {
  //     results = result.items;
  //     print(
  //         'Paginated result: ${result.totalResultsFetched} artists, hasNextPage: ${result.hasNextPage}');
  //   } else {
  //     results = result as List<ArtistDetailed>;
  //   }

  //   expect(results, isNotEmpty);
  //   print('Found ${results.length} artists');

  //   // Print first few results for inspection
  //   for (int i = 0; i < results.length && i < 5; i++) {
  //     final artist = results[i];
  //     print('Artist $i: ${artist.name}');
  //   }

  //   // Check if pagination is working - if we get more than 20 results, pagination is supported
  //   if (results.length > 20) {
  //     print(
  //         'Pagination is supported! Retrieved ${results.length} artists total.');
  //   } else {
  //     print(
  //         'Pagination may not be supported or there are not enough results to paginate.');
  //   }
  // });

  // test('searchArtists with paginated=true should return PaginatedResult',
  //     () async {
  //   final ytmusic = YTMusic();
  //   await ytmusic.initialize();

  //   final result =
  //       await ytmusic.searchArtists('popular artists', paginated: true);

  //   expect(result, isA<PaginatedResult<ArtistDetailed>>());
  //   final paginatedResult = result as PaginatedResult<ArtistDetailed>;

  //   expect(paginatedResult.items, isNotEmpty);
  //   print(
  //       'Paginated result: ${paginatedResult.items.length} artists, hasNextPage: ${paginatedResult.hasNextPage}, totalFetched: ${paginatedResult.totalResultsFetched}');

  //   // Should have a continuation token if there are more pages
  //   if (paginatedResult.hasNextPage) {
  //     expect(paginatedResult.continuationToken, isNotNull);
  //     print('Continuation token available for next page');
  //   }

  //   // Print first few results for inspection
  //   for (int i = 0; i < paginatedResult.items.length && i < 3; i++) {
  //     final artist = paginatedResult.items[i];
  //     print('Artist $i: ${artist.name}');
  //   }
  // });

  // test('searchAlbums should retrieve albums and check for pagination',
  //     () async {
  //   final ytmusic = YTMusic();
  //   await ytmusic.initialize();

  //   final result = await ytmusic.searchAlbums('popular albums');

  //   // Handle both List<AlbumDetailed> and PaginatedResult<AlbumDetailed>
  //   List<AlbumDetailed> results;
  //   if (result is PaginatedResult<AlbumDetailed>) {
  //     results = result.items;
  //     print(
  //         'Paginated result: ${result.totalResultsFetched} albums, hasNextPage: ${result.hasNextPage}');
  //   } else {
  //     results = result as List<AlbumDetailed>;
  //   }

  //   expect(results, isNotEmpty);
  //   print('Found ${results.length} albums');

  //   // Print first few results for inspection
  //   for (int i = 0; i < results.length && i < 5; i++) {
  //     final album = results[i];
  //     print('Album $i: ${album.name} by ${album.artist.name}');
  //   }

  //   // Check if pagination is working - if we get more than 20 results, pagination is supported
  //   if (results.length > 20) {
  //     print(
  //         'Pagination is supported! Retrieved ${results.length} albums total.');
  //   } else {
  //     print(
  //         'Pagination may not be supported or there are not enough results to paginate.');
  //   }
  // });

  // test('searchAlbums with paginated=true should return PaginatedResult',
  //     () async {
  //   final ytmusic = YTMusic();
  //   await ytmusic.initialize();

  //   final result =
  //       await ytmusic.searchAlbums('popular albums', paginated: true);

  //   expect(result, isA<PaginatedResult<AlbumDetailed>>());
  //   final paginatedResult = result as PaginatedResult<AlbumDetailed>;

  //   expect(paginatedResult.items, isNotEmpty);
  //   print(
  //       'Paginated result: ${paginatedResult.items.length} albums, hasNextPage: ${paginatedResult.hasNextPage}, totalFetched: ${paginatedResult.totalResultsFetched}');

  //   // Should have a continuation token if there are more pages
  //   if (paginatedResult.hasNextPage) {
  //     expect(paginatedResult.continuationToken, isNotNull);
  //     print('Continuation token available for next page');
  //   }

  //   // Print first few results for inspection
  //   for (int i = 0; i < paginatedResult.items.length && i < 3; i++) {
  //     final album = paginatedResult.items[i];
  //     print('Album $i: ${album.name} by ${album.artist.name}');
  //   }
  // });

  // test('getUpNexts should retrieve up next songs and check for pagination',
  //     () async {
  //   final ytmusic = YTMusic();
  //   await ytmusic.initialize();

  //   final result = await ytmusic
  //       .getUpNexts('LDY4Bf8Zwn8'); // Using the same video ID from example

  //   // Handle both List<UpNextsDetails> and PaginatedResult<UpNextsDetails>
  //   List<UpNextsDetails> results;
  //   if (result is PaginatedResult<UpNextsDetails>) {
  //     results = result.items;
  //     print(
  //         'Paginated result: ${result.totalResultsFetched} up next songs, hasNextPage: ${result.hasNextPage}');
  //   } else {
  //     results = result as List<UpNextsDetails>;
  //   }

  //   expect(results, isNotEmpty);
  //   print('Found ${results.length} up next songs');

  //   // Print first few results for inspection
  //   for (int i = 0; i < results.length && i < 5; i++) {
  //     final song = results[i];
  //     print('Up Next $i: ${song.title} by ${song.artists.name}');
  //   }

  //   // Check if pagination is working - if we get more than 20 results, pagination is supported
  //   if (results.length > 20) {
  //     print(
  //         'Pagination is supported! Retrieved ${results.length} up next songs total.');
  //   } else {
  //     print(
  //         'Pagination may not be supported or there are not enough results to paginate.');
  //   }
  // });

  // test('getUpNexts with paginated=true should return PaginatedResult',
  //     () async {
  //   final ytmusic = YTMusic();
  //   await ytmusic.initialize();

  //   final result = await ytmusic.getUpNexts('LDY4Bf8Zwn8', paginated: true);

  //   expect(result, isA<PaginatedResult<UpNextsDetails>>());
  //   final paginatedResult = result as PaginatedResult<UpNextsDetails>;

  //   expect(paginatedResult.items, isNotEmpty);
  //   print(
  //       'Paginated result: ${paginatedResult.items.length} up next songs, hasNextPage: ${paginatedResult.hasNextPage}, totalFetched: ${paginatedResult.totalResultsFetched}');

  //   // Should have a continuation token if there are more pages
  //   if (paginatedResult.hasNextPage) {
  //     expect(paginatedResult.continuationToken, isNotNull);
  //     print('Continuation token available for next page');
  //   }

  //   // Print first few results for inspection
  //   for (int i = 0; i < paginatedResult.items.length && i < 3; i++) {
  //     final song = paginatedResult.items[i];
  //     print('Up Next $i: ${song.title} by ${song.artists.name}');
  //   }
  // });

  // test('getUpNexts with continuationToken should return next page', () async {
  //   final ytmusic = YTMusic();
  //   await ytmusic.initialize();

  //   // First get the first page
  //   final firstPageResult =
  //       await ytmusic.getUpNexts('LDY4Bf8Zwn8', paginated: true);
  //   expect(firstPageResult, isA<PaginatedResult<UpNextsDetails>>());
  //   final firstPage = firstPageResult as PaginatedResult<UpNextsDetails>;

  //   if (firstPage.hasNextPage && firstPage.continuationToken != null) {
  //     // Get the second page using continuation token
  //     final secondPageResult = await ytmusic.getUpNexts('LDY4Bf8Zwn8',
  //         paginated: true, continuationToken: firstPage.continuationToken);
  //     expect(secondPageResult, isA<PaginatedResult<UpNextsDetails>>());
  //     final secondPage = secondPageResult as PaginatedResult<UpNextsDetails>;

  //     print('First page: ${firstPage.items.length} songs');
  //     print('Second page: ${secondPage.items.length} songs');

  //     // Verify that the pages are different (first song should be different)
  //     expect(firstPage.items.first.title,
  //         isNot(equals(secondPage.items.first.title)));

  //     // Print first few results from second page
  //     for (int i = 0; i < secondPage.items.length && i < 3; i++) {
  //       final song = secondPage.items[i];
  //       print('Page 2 - Up Next $i: ${song.title} by ${song.artists.name}');
  //     }
  //   } else {
  //     print('No continuation token available, skipping continuation test');
  //   }
  // });

  // test('getPlaylist should work with RD playlist IDs', () async {
  //   final ytmusic = YTMusic();
  //   await ytmusic.initialize();

  //   // Test with a playlist ID that starts with RD (Radio/Recommended playlist)
  //   // RD playlist IDs now work with getPlaylist method thanks to VL prefix fix
  //   final playlist = await ytmusic
  //       .getPlaylistWithRelated('RDCLAK5uy_nfs_t4FUu00E5ED6lveEBBX1VMYe1mFjk');
  //   expect(playlist, isNotNull);
  //   expect(playlist.name, isNotEmpty);
  //   expect(playlist.videoCount,
  //       greaterThan(0)); // Should now have proper video count
  //   print('✅ RD playlist ID works with getPlaylist');
  //   print('Playlist name: ${playlist.name}');
  //   print('Playlist artist: ${playlist.artist.name}');
  //   print('Video count: ${playlist.videoCount}');
  //   print('Playlist ID: ${playlist.playlistId}');
  // });

  // test('getPlaylistVideos should work with RD playlist IDs', () async {
  //   final ytmusic = YTMusic();
  //   await ytmusic.initialize();

  //   // Test with a playlist ID that starts with RD
  //   // Note: According to README, getPlaylistVideos is not working as expected
  //   try {
  //     final videos = await ytmusic
  //         .getPlaylistVideos('RDCLAK5uy_nfs_t4FUu00E5ED6lveEBBX1VMYe1mFjk');
  //     expect(videos, isNotEmpty);
  //     print('✅ RD playlist ID works with getPlaylistVideos');
  //     print('Found ${videos.length} videos in playlist');

  //     // Print first few videos for inspection
  //     for (int i = 0; i < videos.length && i < 3; i++) {
  //       final video = videos[i];
  //       print('Video $i: ${video.name} by ${video.artist.name}');
  //     }
  //   } catch (e) {
  //     print('❌ RD playlist ID failed with getPlaylistVideos - Error: $e');
  //     print('Note: getPlaylistVideos is known to have issues (see README)');
  //   }
  // });

  // test('getPlaylist should handle different RD playlist ID formats', () async {
  //   final ytmusic = YTMusic();
  //   await ytmusic.initialize();

  //   // Test various RD playlist ID formats
  //   final testPlaylistIds = [
  //     'RDCLAK5uy_nfs_t4FUu00E5ED6lveEBBX1VMYe1mFjk', // Standard RD playlist
  //     'RDAMVM_LD-Y4Bf8Zwn8', // RDAMVM format (used in getUpNexts)
  //   ];

  //   for (final playlistId in testPlaylistIds) {
  //     try {
  //       final playlist = await ytmusic.getPlaylistWithRelated(playlistId);
  //       expect(playlist, isNotNull);
  //       expect(playlist.name, isNotEmpty);
  //       print('✅ Playlist ID $playlistId works - Name: ${playlist.name}');
  //     } catch (e) {
  //       print('❌ Playlist ID $playlistId failed - Error: $e');
  //       // Some RD playlist formats might not work, so we don't fail the test
  //     }
  //   }
  // });

  // test('RD playlist IDs are used in getUpNexts method', () async {
  //   final ytmusic = YTMusic();
  //   await ytmusic.initialize();

  //   // Test that getUpNexts works (it uses RDAMVM format internally)
  //   final upNextSongs = await ytmusic.getUpNexts('LDY4Bf8Zwn8');

  //   expect(upNextSongs, isNotEmpty);
  //   print('✅ getUpNexts works and uses RDAMVM playlist ID format internally');
  //   print('Found ${upNextSongs.length} up next songs');

  //   // Verify that the internal playlist ID format is RDAMVM + videoId
  //   // This is used in the getUpNexts method: "playlistId": "RDAMVM$videoId"
  //   final expectedPlaylistId = 'RDAMVM_LD-Y4Bf8Zwn8';
  //   print('Internal playlist ID format used: $expectedPlaylistId');
  // });

  // test('getUpNexts durations should be present or zero', () async {
  //   final ytmusic = YTMusic();
  //   await ytmusic.initialize();

  //   final result = await ytmusic.getUpNexts('LDY4Bf8Zwn8');

  //   // Normalize to List<UpNextsDetails>
  //   List<UpNextsDetails> results;
  //   if (result is PaginatedResult<UpNextsDetails>) {
  //     results = result.items;
  //   } else {
  //     results = result as List<UpNextsDetails>;
  //   }

  //   expect(results, isNotEmpty);

  //   // At least one item should have a positive duration
  //   final hasPositiveDuration = results.any((s) => s.duration > 0);
  //   expect(hasPositiveDuration, isTrue,
  //       reason: 'At least one up next song should have a positive duration');

  //   // Each duration must be an int and non-negative
  //   for (final s in results.take(8)) {
  //     print('UpNext: ${s.title} duration: ${s.duration}');
  //     expect(s.duration, isA<int>());
  //     expect(s.duration >= 0, isTrue);
  //   }
  // });

  // test('getSong should retrieve song details including streaming formats',
  //     () async {
  //   final ytmusic = YTMusic();
  //   await ytmusic.initialize();

  //   final song = await ytmusic.getSong('6Mfe_tMuDfg');

  //   expect(song, isA<SongFull>());
  //   expect(song.videoId, equals('6Mfe_tMuDfg'));
  //   expect(song.name, isNotEmpty);
  //   expect(song.artist.name, isNotEmpty);
  //   expect(song.duration, greaterThan(0));
  //   expect(song.thumbnails, isNotEmpty);

  //   print('✅ getSong retrieved song details:');
  //   print('Video ID: ${song.videoId}');
  //   print('Name: ${song.name}');
  //   print('Artist: ${song.artist.name}');
  //   print('Duration: ${song.duration} seconds');
  //   print('Thumbnails count: ${song.thumbnails.length}');

  //   // Check streaming formats
  //   print('Formats count: ${song.formats.length}');
  //   if (song.formats.isNotEmpty) {
  //     print('First format sample:');
  //     print(song.formats[0]);
  //   }

  //   print('Adaptive Formats count: ${song.adaptiveFormats.length}');
  //   if (song.adaptiveFormats.isNotEmpty) {
  //     print('First adaptive format sample:');
  //     print(song.adaptiveFormats[0]);

  //     // Look for audio-only formats
  //     final audioFormats = song.adaptiveFormats.where((format) {
  //       final mimeType = format['mimeType']?.toString() ?? '';
  //       return mimeType.contains('audio/');
  //     }).toList();

  //     print('Audio-only formats found: ${audioFormats.length}');
  //     for (int i = 0; i < audioFormats.length; i++) {
  //       final format = audioFormats[i];
  //       print('Audio Format ${i + 1}:');
  //       print('  itag: ${format['itag']}');
  //       print('  mimeType: ${format['mimeType']}');
  //       print('  bitrate: ${format['bitrate']}');
  //       print('  audioQuality: ${format['audioQuality']}');
  //       print('  contentLength: ${format['contentLength']}');
  //       print('  approxDurationMs: ${format['approxDurationMs']}');
  //       print('');
  //     }

  //     if (audioFormats.isNotEmpty) {
  //       print('Best audio format (highest bitrate):');
  //       audioFormats.sort((a, b) {
  //         final aBitrate = int.tryParse(a['bitrate']?.toString() ?? '0') ?? 0;
  //         final bBitrate = int.tryParse(b['bitrate']?.toString() ?? '0') ?? 0;
  //         return bBitrate.compareTo(aBitrate);
  //       });
  //       final bestAudio = audioFormats.first;
  //       print(
  //           'itag: ${bestAudio['itag']}, mimeType: ${bestAudio['mimeType']}, bitrate: ${bestAudio['bitrate']}');
  //       print('Audio URL: ${bestAudio['url'] ?? bestAudio['signatureCipher']}');

  //       // Print detailed information about the signatureCipher
  //       final signatureCipher = bestAudio['signatureCipher'] as String?;
  //       if (signatureCipher != null) {
  //         print('\n🔍 SignatureCipher Analysis:');
  //         print('Raw signatureCipher: $signatureCipher');

  //         try {
  //           // Parse the signatureCipher to extract components
  //           final params = Uri.splitQueryString(signatureCipher);
  //           print('Parsed parameters:');
  //           params.forEach((key, value) {
  //             if (key == 's') {
  //               print('  $key: $value');
  //             } else if (key == 'url') {
  //               print('  $key: $value)');
  //             } else {
  //               print('  $key: $value');
  //             }
  //           });
  //         } catch (e) {
  //           print('❌ Error parsing signatureCipher: $e');
  //         }
  //       } else {
  //         print('❌ No signatureCipher found');
  //       }
  //     }
  //   }
  // });

  test("test for artist with id", () async {
    final ytmusic = YTMusic();
    await ytmusic.initialize();

    final artist = await ytmusic.getArtist("UCzAn-hBNSTjX-QMnHASZFfA");

    expect(artist, isA<ArtistFull>());
    expect(artist.artistId, equals("UCzAn-hBNSTjX-QMnHASZFfA"));
    expect(artist.name, isNotEmpty);
    expect(artist.thumbnails, isNotEmpty);

    print('\n🎤 Artist Details:');
    print('Name: ${artist.name}');
    print('Artist/Channel ID: ${artist.artistId}');
    print('Is Channel ID (UC*): ${artist.artistId.startsWith('UC')}');
    print('Thumbnails count: ${artist.thumbnails.length}');

    print('\n✅ Verifying Featured On playlists:');
    for (int i = 0; i < artist.featuredOn.length; i++) {
      final playlist = artist.featuredOn[i];
      print(
          'Playlist $i: ${playlist.playlistId} - ${playlist.name} by ${playlist.artist.name}');

      // Assert that playlistId is not empty and does NOT start with UC
      expect(playlist.playlistId, isNotEmpty,
          reason: 'Playlist ID should not be empty');
      expect(playlist.playlistId.startsWith('UC'), isFalse,
          reason:
              'Featured On should not contain channel IDs (UC*), found: ${playlist.playlistId}');

      // Verify it's a valid playlist ID format (VL*, PL*, RD*, OLAK*)
      final isValidPlaylist = playlist.playlistId.startsWith('VL') ||
          playlist.playlistId.startsWith('PL') ||
          playlist.playlistId.startsWith('RD') ||
          playlist.playlistId.startsWith('OLAK');
      expect(isValidPlaylist, isTrue,
          reason:
              'Playlist ID should start with VL, PL, RD, or OLAK, found: ${playlist.playlistId}');
    }

    print(
        '\n✅ All featuredOn items are valid playlists (no channel IDs found)');

    // Build headings locally (no longer stored on ArtistFull)
    final headings = [
      artist.topAlbumsTitle,
      artist.topSinglesTitle,
      artist.topVideosTitle,
      artist.featuredOnTitle,
      artist.playlistsByArtistTitle,
      artist.similarArtistsTitle,
      artist.topSongsTitle,
    ].where((t) => t != null).cast<String>().toList();

    print('\n📋 Headings: ${headings.length}');

    // Map headings to their data
    Map<String, dynamic> sectionData = {
      if (artist.topSongsTitle != null) artist.topSongsTitle!: artist.topSongs,
      if (artist.topAlbumsTitle != null)
        artist.topAlbumsTitle!: artist.topAlbums,
      if (artist.topSinglesTitle != null)
        artist.topSinglesTitle!: artist.topSingles,
      if (artist.topVideosTitle != null)
        artist.topVideosTitle!: artist.topVideos,
      if (artist.featuredOnTitle != null)
        artist.featuredOnTitle!: artist.featuredOn,
      if (artist.playlistsByArtistTitle != null)
        artist.playlistsByArtistTitle!: artist.playlistsByArtist,
      if (artist.similarArtistsTitle != null)
        artist.similarArtistsTitle!: artist.similarArtists,
    };

    print('\n📋 Headings with Data:');
    headings.forEach((heading) {
      final data = sectionData[heading];
      if (data != null) {
        print('  - $heading: ${data.length} items');
        if (data is List && data.isNotEmpty) {
          // Print first 3 items as examples
          for (int i = 0; i < data.length && i < 3; i++) {
            final item = data[i];
            if (item is SongDetailed) {
              print(
                  '    ${i + 1}. ${item.name} by ${item.artist.name} (${item.videoId})');
            } else if (item is AlbumDetailed) {
              print(
                  '    ${i + 1}. ${item.name} by ${item.artist.name} (${item.albumId})');
            } else if (item is VideoDetailed) {
              print(
                  '    ${i + 1}. ${item.name} by ${item.artist.name} (${item.videoId})');
            } else if (item is PlaylistDetailed) {
              print(
                  '    ${i + 1}. ${item.name} by ${item.artist.name} (${item.playlistId})');
            } else if (item is ArtistDetailed) {
              print('    ${i + 1}. ${item.name} (${item.artistId})');
            }
          }
        }
      } else {
        print('  - $heading: No data mapped');
      }
    });

    // Collect detailed data for JSON output
    Map<String, dynamic> detailedOutput = {
      "artistDetails": {
        "name": artist.name,
        "artistId": artist.artistId,
        "isChannelId": artist.artistId.startsWith('UC'),
        "thumbnailsCount": artist.thumbnails.length,
        "thumbnails": artist.thumbnails
            .map((t) => {"url": t.url, "width": t.width, "height": t.height})
            .toList(),
        "subtitle": artist.subtitle,
        "monthlyListenerCount": artist.monthlyListenerCount,
        "shuffleNavigationEndpoint": artist.shuffleNavigationEndpoint,
        "mixNavigationEndpoint": artist.mixNavigationEndpoint,
        "topSongsShowAllNavigationEndpoint":
            artist.topSongsShowAllNavigationEndpoint,
        "sectionShowAllNavigationEndpoints":
            artist.sectionShowAllNavigationEndpoints,
        "subscriberCount": artist.subscriberCount
      },
      "headings": headings,
      "sections": {},
      "about": artist.about
    };

    // Populate sections
    headings.forEach((heading) {
      dynamic data;
      final hl = heading.toLowerCase();

      // Map data based on heading content
      if (hl.contains('album') && !hl.contains('single')) {
        data = sectionData[artist.topAlbumsTitle];
      } else if (hl.contains('single') || hl.contains('ep')) {
        data = sectionData[artist.topSinglesTitle];
      } else if (hl.contains('video')) {
        data = sectionData[artist.topVideosTitle];
      } else if (hl.contains('feature') ||
          hl.contains('appear') ||
          hl.contains('live')) {
        data = artist.featuredOn;
      } else if (hl.contains('playlist') && hl.contains('by')) {
        data = sectionData[artist.playlistsByArtistTitle];
      } else if (hl.contains('similar') ||
          hl.contains('fan') ||
          hl.contains('like')) {
        data = sectionData[artist.similarArtistsTitle];
      } else if (hl.contains('top') && hl.contains('song')) {
        data = sectionData[artist.topSongsTitle];
      }

      if (data != null && data is List) {
        detailedOutput["sections"][heading] = data.map((item) {
          if (item is SongDetailed) {
            return {
              "type": "song",
              "name": item.name,
              "artist": item.artist.name,
              "videoId": item.videoId,
              "album": item.album?.name,
              "duration": item.duration
            };
          } else if (item is AlbumDetailed) {
            return {
              "type": "album",
              "name": item.name,
              "artist": item.artist.name,
              "albumId": item.albumId,
              "year": item.year
            };
          } else if (item is VideoDetailed) {
            return {
              "type": "video",
              "name": item.name,
              "artist": item.artist.name,
              "videoId": item.videoId,
              "duration": item.duration
            };
          } else if (item is PlaylistDetailed) {
            return {
              "type": "playlist",
              "name": item.name,
              "artist": item.artist.name,
              "playlistId": item.playlistId,
              "views": item.views,
              "shuffleNavigationEndpoint": item.shuffleNavigationEndpoint,
              "mixNavigationEndpoint": item.mixNavigationEndpoint
            };
          } else if (item is ArtistDetailed) {
            return {
              "type": "artist",
              "name": item.name,
              "artistId": item.artistId,
              "subtitle": item.subtitle
            };
          }
          return {};
        }).toList();
      } else {
        detailedOutput["sections"][heading] = [];
      }
    });

    // Sanitize output to remove any 'clickTrackingParams' remnants
    final cleaned = stripClickTrackingParams(detailedOutput);

    // Save to JSON file
    File('${artist.name}.json').writeAsStringSync(jsonEncode(cleaned));
    print('Detailed output saved to ${artist.name}.json');
  });
}

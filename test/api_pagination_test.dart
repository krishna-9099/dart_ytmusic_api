import 'package:test/test.dart';
import 'package:dart_ytmusic_api/yt_music.dart';
import 'package:dart_ytmusic_api/types.dart';

void main() {
  group('API Level Pagination Tests', () {
    late YTMusic ytMusic;

    setUpAll(() async {
      ytMusic = YTMusic();
      await ytMusic.initialize();
    });

    group('searchSongs Pagination', () {
      test('should return different results for different pages', () async {
        final firstPageResult = await ytMusic.searchSongs('popular songs',
            paginated: true) as PaginatedResult<SongDetailed>;
        expect(firstPageResult.items, isNotEmpty);
        expect(firstPageResult.hasNextPage, isTrue);
        expect(firstPageResult.continuationToken, isNotNull);

        print(
            'First page: ${firstPageResult.items.length} songs, hasNextPage: ${firstPageResult.hasNextPage}');
        print('Continuation token: ${firstPageResult.continuationToken}');

        final firstPageSongIds =
            firstPageResult.items.map((song) => song.videoId).toSet();
        final firstPageSongTitles =
            firstPageResult.items.map((song) => song.name).toSet();

        print('First page song IDs: $firstPageSongIds');
        print('First page song titles: $firstPageSongTitles');

        // Get second page using continuation token
        final secondPageResult = await ytMusic.searchSongs('popular songs',
                paginated: true,
                continuationToken: firstPageResult.continuationToken)
            as PaginatedResult<SongDetailed>;
        expect(secondPageResult.items, isNotEmpty);

        print(
            'Second page: ${secondPageResult.items.length} songs, hasNextPage: ${secondPageResult.hasNextPage}');

        final secondPageSongIds =
            secondPageResult.items.map((song) => song.videoId).toSet();
        final secondPageSongTitles =
            secondPageResult.items.map((song) => song.name).toSet();

        print('Second page song IDs: $secondPageSongIds');
        print('Second page song titles: $secondPageSongTitles');

        // Check for overlap
        final commonSongIds = firstPageSongIds.intersection(secondPageSongIds);
        final commonSongTitles =
            firstPageSongTitles.intersection(secondPageSongTitles);

        print('Common song IDs between pages: $commonSongIds');
        print('Common song titles between pages: $commonSongTitles');

        final overlapPercentage =
            (commonSongIds.length / firstPageSongIds.length) * 100;
        print('Overlap percentage: ${overlapPercentage.toStringAsFixed(2)}%');

        // Assert no overlap (or very minimal overlap)
        expect(commonSongIds.length, lessThan(3),
            reason: 'Should have minimal or no duplicate songs between pages');
        expect(overlapPercentage, lessThan(15.0),
            reason: 'Overlap should be less than 15%');
      });

      test('should handle continuation token correctly', () async {
        final firstPageResult = await ytMusic.searchSongs('popular songs',
            paginated: true) as PaginatedResult<SongDetailed>;
        expect(firstPageResult.continuationToken, isNotNull);

        // Use continuation token to get next page
        final secondPageResult = await ytMusic.searchSongs('popular songs',
                paginated: true,
                continuationToken: firstPageResult.continuationToken)
            as PaginatedResult<SongDetailed>;

        // Results should be different
        final firstPageIds =
            firstPageResult.items.map((song) => song.videoId).toSet();
        final secondPageIds =
            secondPageResult.items.map((song) => song.videoId).toSet();
        final overlap = firstPageIds.intersection(secondPageIds);

        expect(overlap.length, lessThan(firstPageResult.items.length),
            reason: 'Pages should have different results');
      });
    });

    group('searchVideos Pagination', () {
      test('should return different results for different pages', () async {
        final firstPageResult =
            await ytMusic.searchVideos('popular music videos', paginated: true)
                as PaginatedResult<VideoDetailed>;
        expect(firstPageResult.items, isNotEmpty);
        expect(firstPageResult.hasNextPage, isTrue);
        expect(firstPageResult.continuationToken, isNotNull);

        print(
            'First page: ${firstPageResult.items.length} videos, hasNextPage: ${firstPageResult.hasNextPage}');

        final firstPageVideoIds =
            firstPageResult.items.map((video) => video.videoId).toSet();
        final firstPageVideoTitles =
            firstPageResult.items.map((video) => video.name).toSet();

        // Get second page using continuation token
        final secondPageResult = await ytMusic.searchVideos(
                'popular music videos',
                paginated: true,
                continuationToken: firstPageResult.continuationToken)
            as PaginatedResult<VideoDetailed>;
        expect(secondPageResult.items, isNotEmpty);

        print(
            'Second page: ${secondPageResult.items.length} videos, hasNextPage: ${secondPageResult.hasNextPage}');

        final secondPageVideoIds =
            secondPageResult.items.map((video) => video.videoId).toSet();
        final secondPageVideoTitles =
            secondPageResult.items.map((video) => video.name).toSet();

        // Check for overlap
        final commonVideoIds =
            firstPageVideoIds.intersection(secondPageVideoIds);
        final commonVideoTitles =
            firstPageVideoTitles.intersection(secondPageVideoTitles);

        print('Common video IDs between pages: $commonVideoIds');
        print('Common video titles between pages: $commonVideoTitles');

        final overlapPercentage =
            (commonVideoIds.length / firstPageVideoIds.length) * 100;
        print('Overlap percentage: ${overlapPercentage.toStringAsFixed(2)}%');

        // Assert minimal overlap (some overlap is acceptable for videos)
        expect(commonVideoIds.length, lessThan(firstPageVideoIds.length),
            reason: 'Should have different videos between pages');
        expect(overlapPercentage, lessThan(25.0),
            reason: 'Overlap should be less than 25%');
      });
    });

    group('searchArtists Pagination', () {
      test('should return different results for different pages', () async {
        final firstPageResult = await ytMusic.searchArtists('popular artists',
            paginated: true) as PaginatedResult<ArtistDetailed>;
        expect(firstPageResult.items, isNotEmpty);
        // Note: Some queries may not have enough results to paginate, so we don't enforce hasNextPage here
        expect(
            firstPageResult.continuationToken != null ||
                !firstPageResult.hasNextPage,
            isTrue,
            reason: 'Either has continuation token or no next page');

        print(
            'First page: ${firstPageResult.items.length} artists, hasNextPage: ${firstPageResult.hasNextPage}');

        final firstPageArtistNames =
            firstPageResult.items.map((artist) => artist.name).toSet();

        // Skip pagination test if no continuation token (not enough results to paginate)
        if (!firstPageResult.hasNextPage ||
            firstPageResult.continuationToken == null) {
          print('Skipping pagination test - not enough artists to paginate');
          return;
        }

        // Get second page using continuation token
        final secondPageResult = await ytMusic.searchArtists('popular artists',
                paginated: true,
                continuationToken: firstPageResult.continuationToken)
            as PaginatedResult<ArtistDetailed>;
        expect(secondPageResult.items, isNotEmpty);

        print(
            'Second page: ${secondPageResult.items.length} artists, hasNextPage: ${secondPageResult.hasNextPage}');

        final secondPageArtistNames =
            secondPageResult.items.map((artist) => artist.name).toSet();

        // Check for overlap
        final commonArtistNames =
            firstPageArtistNames.intersection(secondPageArtistNames);

        print('Common artist names between pages: $commonArtistNames');

        final overlapPercentage =
            (commonArtistNames.length / firstPageArtistNames.length) * 100;
        print('Overlap percentage: ${overlapPercentage.toStringAsFixed(2)}%');

        // Assert minimal overlap (or very minimal overlap)
        expect(commonArtistNames.length, lessThan(5),
            reason:
                'Should have minimal or no duplicate artists between pages');
        expect(overlapPercentage, lessThan(25.0),
            reason: 'Overlap should be less than 25%');
      });
    });

    group('searchAlbums Pagination', () {
      test('should return different results for different pages', () async {
        final firstPageResult = await ytMusic.searchAlbums('popular albums',
            paginated: true) as PaginatedResult<AlbumDetailed>;
        expect(firstPageResult.items, isNotEmpty);
        expect(firstPageResult.hasNextPage, isTrue);
        expect(firstPageResult.continuationToken, isNotNull);

        print(
            'First page: ${firstPageResult.items.length} albums, hasNextPage: ${firstPageResult.hasNextPage}');

        final firstPageAlbumNames =
            firstPageResult.items.map((album) => album.name).toSet();

        // Get second page using continuation token
        final secondPageResult = await ytMusic.searchAlbums('popular albums',
                paginated: true,
                continuationToken: firstPageResult.continuationToken)
            as PaginatedResult<AlbumDetailed>;
        expect(secondPageResult.items, isNotEmpty);

        print(
            'Second page: ${secondPageResult.items.length} albums, hasNextPage: ${secondPageResult.hasNextPage}');

        final secondPageAlbumNames =
            secondPageResult.items.map((album) => album.name).toSet();

        // Check for overlap
        final commonAlbumNames =
            firstPageAlbumNames.intersection(secondPageAlbumNames);

        print('Common album names between pages: $commonAlbumNames');

        final overlapPercentage =
            (commonAlbumNames.length / firstPageAlbumNames.length) * 100;
        print('Overlap percentage: ${overlapPercentage.toStringAsFixed(2)}%');

        // Assert minimal overlap (some overlap is acceptable for albums)
        expect(commonAlbumNames.length, lessThan(5),
            reason: 'Should have minimal or no duplicate albums between pages');
        expect(overlapPercentage, lessThan(25.0),
            reason: 'Overlap should be less than 25%');
      });
    });

    group('searchPlaylists Pagination', () {
      test('should return different results for different pages', () async {
        final firstPageResult =
            await ytMusic.searchPlaylists('popular playlists', paginated: true)
                as PaginatedResult<PlaylistDetailed>;
        expect(firstPageResult.items, isNotEmpty);
        expect(firstPageResult.hasNextPage, isTrue);
        expect(firstPageResult.continuationToken, isNotNull);

        print(
            'First page: ${firstPageResult.items.length} playlists, hasNextPage: ${firstPageResult.hasNextPage}');

        final firstPagePlaylistNames =
            firstPageResult.items.map((playlist) => playlist.name).toSet();

        // Get second page using continuation token
        final secondPageResult = await ytMusic.searchPlaylists(
                'popular playlists',
                paginated: true,
                continuationToken: firstPageResult.continuationToken)
            as PaginatedResult<PlaylistDetailed>;
        expect(secondPageResult.items, isNotEmpty);

        print(
            'Second page: ${secondPageResult.items.length} playlists, hasNextPage: ${secondPageResult.hasNextPage}');

        final secondPagePlaylistNames =
            secondPageResult.items.map((playlist) => playlist.name).toSet();

        // Check for overlap
        final commonPlaylistNames =
            firstPagePlaylistNames.intersection(secondPagePlaylistNames);

        print('Common playlist names between pages: $commonPlaylistNames');

        final overlapPercentage =
            (commonPlaylistNames.length / firstPagePlaylistNames.length) * 100;
        print('Overlap percentage: ${overlapPercentage.toStringAsFixed(2)}%');

        // Assert minimal overlap (some overlap is acceptable for playlists)
        expect(
            commonPlaylistNames.length, lessThan(firstPagePlaylistNames.length),
            reason: 'Should have different playlists between pages');
        expect(overlapPercentage, lessThan(25.0),
            reason: 'Overlap should be less than 25%');
      });
    });

    group('Cross-Method Consistency', () {
      test(
          'all search methods should return PaginatedResult when paginated=true',
          () async {
        // Test searchSongs
        final songsResult = await ytMusic.searchSongs('test', paginated: true);
        expect(songsResult, isA<PaginatedResult<SongDetailed>>());

        // Test searchVideos
        final videosResult =
            await ytMusic.searchVideos('test', paginated: true);
        expect(videosResult, isA<PaginatedResult<VideoDetailed>>());

        // Test searchArtists
        final artistsResult =
            await ytMusic.searchArtists('test', paginated: true);
        expect(artistsResult, isA<PaginatedResult<ArtistDetailed>>());

        // Test searchAlbums
        final albumsResult =
            await ytMusic.searchAlbums('test', paginated: true);
        expect(albumsResult, isA<PaginatedResult<AlbumDetailed>>());

        // Test searchPlaylists
        final playlistsResult =
            await ytMusic.searchPlaylists('test', paginated: true);
        expect(playlistsResult, isA<PaginatedResult<PlaylistDetailed>>());
      });

      test('all search methods should support continuation tokens', () async {
        // Get first page for each method
        final songsPage1 = await ytMusic.searchSongs('test', paginated: true)
            as PaginatedResult<SongDetailed>;
        final videosPage1 = await ytMusic.searchVideos('test', paginated: true)
            as PaginatedResult<VideoDetailed>;
        final artistsPage1 = await ytMusic.searchArtists('test',
            paginated: true) as PaginatedResult<ArtistDetailed>;
        final albumsPage1 = await ytMusic.searchAlbums('test', paginated: true)
            as PaginatedResult<AlbumDetailed>;
        final playlistsPage1 = await ytMusic.searchPlaylists('test',
            paginated: true) as PaginatedResult<PlaylistDetailed>;

        // Verify continuation tokens exist
        expect(songsPage1.continuationToken, isNotNull);
        expect(videosPage1.continuationToken, isNotNull);
        expect(artistsPage1.continuationToken, isNotNull);
        expect(albumsPage1.continuationToken, isNotNull);
        expect(playlistsPage1.continuationToken, isNotNull);

        // Test continuation token usage
        final songsPage2 = await ytMusic.searchSongs('test',
            paginated: true, continuationToken: songsPage1.continuationToken);
        final videosPage2 = await ytMusic.searchVideos('test',
            paginated: true, continuationToken: videosPage1.continuationToken);
        final artistsPage2 = await ytMusic.searchArtists('test',
            paginated: true, continuationToken: artistsPage1.continuationToken);
        final albumsPage2 = await ytMusic.searchAlbums('test',
            paginated: true, continuationToken: albumsPage1.continuationToken);
        final playlistsPage2 = await ytMusic.searchPlaylists('test',
            paginated: true,
            continuationToken: playlistsPage1.continuationToken);

        // Verify results are returned
        expect(songsPage2, isA<PaginatedResult<SongDetailed>>());
        expect(videosPage2, isA<PaginatedResult<VideoDetailed>>());
        expect(artistsPage2, isA<PaginatedResult<ArtistDetailed>>());
        expect(albumsPage2, isA<PaginatedResult<AlbumDetailed>>());
        expect(playlistsPage2, isA<PaginatedResult<PlaylistDetailed>>());
      });
    });

    group('Edge Cases', () {
      test('should handle empty results gracefully', () async {
        // Use a query that might return no results
        final result = await ytMusic.searchSongs('xzcvbnmnonexistentquery12345',
            paginated: true) as PaginatedResult<SongDetailed>;

        // Should still return a valid PaginatedResult, even if empty
        expect(result, isA<PaginatedResult<SongDetailed>>());
        expect(result.items, isA<List<SongDetailed>>());
        expect(result.totalResultsFetched, equals(result.items.length));
      });

      test('should handle invalid continuation tokens', () async {
        // Test with invalid continuation token - should throw an exception
        await expectLater(
          ytMusic.searchSongs('test',
              paginated: true, continuationToken: 'invalid_token'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}

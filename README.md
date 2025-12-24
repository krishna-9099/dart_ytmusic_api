# Dart YouTube Music API

This package allows you to interact with YouTube Music data in Dart. You can search for songs, albums, artists, and playlists, retrieve detailed information, and get suggestions.

> **Note:** This package is ported from [ts-npm-ytmusic-api](https://github.com/zS1L3NT/ts-npm-ytmusic-api). Credits to the original author.

## Getting Started

### Installation

You can install the package in your Dart project using the following methods:

#### 1. Using `flutter pub` (for Flutter projects)

```bash
flutter pub add dart_ytmusic_api
```

#### 2. Using `dart pub` (for general Dart projects)

```bash
dart pub add dart_ytmusic_api
```

#### 3. Modifying `pubspec.yaml`

Add the following line to your `pubspec.yaml` file under the `dependencies` section:

```yaml
dependencies:
  dart_ytmusic_api: ^1.3.5
```

Then, run `flutter pub get` (for Flutter projects) or `dart pub get` (for general Dart projects) to install the package.

### Usage
Here's a basic example of how to use the YouTube Music API in Dart:

```dart
import 'package:dart_ytmusic_api/yt_music.dart';

void main() async {
  // Create an instance of the YouTube Music API
  final ytmusic = YTMusic();

  // Initialize the API
  await ytmusic.initialize();

  // There's how you can use a method
  final albumResults = await ytmusic.searchAlbums('query');
}
```

## Pagination Support

This package supports two pagination modes for search methods and `getUpNexts`:

### Auto-Pagination (Default)
By default, all search methods automatically fetch all available results:

```dart
// Automatically fetches all results
final songs = await ytmusic.searchSongs('popular music');
// Returns: List<SongDetailed> with all available songs
```

### UI-Driven Pagination
For better performance in UI applications, you can enable paginated mode to load results in pages:

```dart
// Load first page only (typically 20 results)
final firstPage = await ytmusic.searchSongs('popular music', paginated: true);
// Returns: PaginatedResult<SongDetailed>

// Load next page using continuation token
if (firstPage.hasNextPage) {
  final nextPage = await ytmusic.searchSongs('popular music',
    paginated: true,
    continuationToken: firstPage.continuationToken
  );
}
```

### PaginatedResult Structure
When using `paginated: true`, methods return a `PaginatedResult<T>` object:

```dart
class PaginatedResult<T> {
  final List<T> items;              // Current page results
  final String? continuationToken;  // Token for next page (null if no more pages)
  final bool hasNextPage;          // Whether more pages are available
  final int totalResultsFetched;   // Number of results in current page
}
```

## API Methods

The following methods are available in the `YTMusic` class:

**Initialization**

- `initialize(cookies: String, gl: String, hl: String)`: Initializes the API with the provided cookies, geolocation, and language.

**Search** (All support pagination)

- `getSearchSuggestions(query: String)`: Retrieves search suggestions for a given query.
- `search(query: String)`: Performs a general search for music with the given query.
- `searchSongs(query: String, {bool paginated = false, String? continuationToken})`: Performs a search specifically for songs.
- `searchVideos(query: String, {bool paginated = false, String? continuationToken})`: Performs a search specifically for videos.
- `searchArtists(query: String, {bool paginated = false, String? continuationToken})`: Performs a search specifically for artists.
- `searchAlbums(query: String, {bool paginated = false, String? continuationToken})`: Performs a search specifically for albums.
- `searchPlaylists(query: String, {bool paginated = false, String? continuationToken})`: Performs a search specifically for playlists.

**Retrieve Details**

- `getSong(videoId: String)`: Retrieves detailed information about a song given its video ID.
- `getVideo(videoId: String)`: Retrieves detailed information about a video given its video ID.
- `getLyrics(videoId: String)`: Retrieves the lyrics of a song given its video ID.
- `getTimedLyrics(String videoId)`: Retrieves the timed lyrics (lyrics synchronized with audio playback times) for a song given its video ID.
- `getUpNexts(String videoId, {bool paginated = false, String? continuationToken})`: Retrieves a list of suggested up next songs for a given video ID.
- `getArtist(artistId: String)`: Retrieves detailed information about an artist given its artist ID.
- `getAlbum(albumId: String)`: Retrieves detailed information about an album given its album ID.
- `getPlaylist(playlistId: String)`: Retrieves detailed information about a playlist given its playlist ID.

**Artist Methods**

- `getArtistSongs(artistId: String)`: Retrieves a list of songs by a specific artist.
- `getArtistAlbums(artistId: String)`: Retrieves a list of albums by a specific artist.
- `getArtistSingles(artistId: String)`: Retrieves a list of singles by a specific artist.

**Playlist Methods**

- `getPlaylistVideos(playlistId: String)`: Retrieves a list of videos from a playlist given its playlist ID.

**Home Section**

- `getHomeSections()`: Retrieves the home sections of the music platform.

## Advanced Usage Examples

### Infinite Scroll Implementation

```dart
import 'package:dart_ytmusic_api/yt_music.dart';
import 'package:dart_ytmusic_api/types.dart';

class MusicSearchScreen {
  final YTMusic _ytmusic = YTMusic();
  List<SongDetailed> _songs = [];
  String? _continuationToken;
  bool _hasMorePages = true;

  Future<void> initialize() async {
    await _ytmusic.initialize();
  }

  Future<void> searchSongs(String query) async {
    // Load first page
    final result = await _ytmusic.searchSongs(query, paginated: true);

    if (result is PaginatedResult<SongDetailed>) {
      _songs = result.items;
      _continuationToken = result.continuationToken;
      _hasMorePages = result.hasNextPage;
    }
  }

  Future<void> loadMoreSongs() async {
    if (!_hasMorePages || _continuationToken == null) return;

    final result = await _ytmusic.searchSongs('your query',
      paginated: true,
      continuationToken: _continuationToken
    );

    if (result is PaginatedResult<SongDetailed>) {
      _songs.addAll(result.items);
      _continuationToken = result.continuationToken;
      _hasMorePages = result.hasNextPage;
    }
  }
}
```

### Handling Dynamic Return Types

```dart
Future<void> handleSearchResults(String query) async {
  final ytmusic = YTMusic();
  await ytmusic.initialize();

  // Auto-pagination mode
  final autoResults = await ytmusic.searchSongs(query);
  if (autoResults is List<SongDetailed>) {
    print('Found ${autoResults.length} songs (all results)');
  }

  // Paginated mode
  final paginatedResults = await ytmusic.searchSongs(query, paginated: true);
  if (paginatedResults is PaginatedResult<SongDetailed>) {
    print('Found ${paginatedResults.items.length} songs (first page)');
    print('Has more pages: ${paginatedResults.hasNextPage}');
  }
}
```

### Up Next Songs with Pagination

```dart
Future<void> loadUpNextSongs(String videoId) async {
  final ytmusic = YTMusic();
  await ytmusic.initialize();

  // Load first 20 up next songs
  final firstPage = await ytmusic.getUpNexts(videoId, paginated: true);
  if (firstPage is PaginatedResult<UpNextsDetails>) {
    print('First page: ${firstPage.items.length} songs');

    // Load more if available
    if (firstPage.hasNextPage) {
      final nextPage = await ytmusic.getUpNexts(videoId,
        paginated: true,
        continuationToken: firstPage.continuationToken
      );
      print('Next page: ${nextPage.items.length} songs');
    }
  }
}
```

## Known Issues

- **`getPlaylistVideos` is not working as expected.** The method currently returns an "Invalid request" error. This issue is under investigation.
- **RD playlist IDs are not supported by `getPlaylist()` and `getPlaylistVideos()`.** Playlist IDs starting with "RD" (Radio/Recommended playlists) return 400 errors when used with these methods. However, RD playlist IDs are used internally by the `getUpNexts()` method with the format `RDAMVM${videoId}` for retrieving up next songs.

  **Note:** This is a known limitation across YouTube Music API implementations. A similar issue was reported in the original TypeScript library ([ts-npm-ytmusic-api#57](https://github.com/zS1L3NT/ts-npm-ytmusic-api/issues/57)), and a fix was implemented in a fork that treats RD playlists the same as regular playlists by adding a "VL" prefix for the browse request. This suggests the issue could be resolved with similar modifications to support RD playlist fetching.

## Contributing

Contributions are welcome! Please feel free to open issues, submit pull requests, or reach out if you have any questions.

## License

This project is licensed under the GNU General Public License version 3. See the [LICENSE](LICENSE) file for details.

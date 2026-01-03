import 'package:test/test.dart';
import 'package:dart_ytmusic_api/parsers/artist_parser.dart';
import 'package:dart_ytmusic_api/types.dart';

void main() {
  test('ArtistParser parses section titles from renderer data', () {
    final data = {
      'header': {
        'title': {'text': 'Test Artist'},
        'thumbnails': [
          {'url': 'https://example.com/t.jpg', 'width': 100, 'height': 100}
        ]
      },
      'musicShelfRenderer': {
        'title': {
          'runs': [
            {'text': 'Top Tracks'}
          ]
        },
        'contents': []
      },
      'musicCarouselShelfRenderer': [
        {
          'title': {
            'runs': [
              {'text': 'Albums Section'}
            ]
          },
          'contents': []
        },
        {
          'title': {
            'runs': [
              {'text': 'Singles Section'}
            ]
          },
          'contents': []
        },
        {
          'title': {
            'runs': [
              {'text': 'Videos Section'}
            ]
          },
          'contents': []
        },
        {
          'title': {
            'runs': [
              {'text': 'Featured Playlists'}
            ]
          },
          'contents': []
        },
        {
          'title': {
            'runs': [
              {'text': 'Similar Artists'}
            ]
          },
          'contents': []
        }
      ]
    };

    final artist = ArtistParser.parse(data, 'AR123');

    expect(artist.name, equals('Test Artist'));
    expect(artist.topSongsTitle, equals('Top Tracks'));
    expect(artist.topAlbumsTitle, equals('Albums Section'));
    expect(artist.topSinglesTitle, equals('Singles Section'));
    expect(artist.topVideosTitle, equals('Videos Section'));
    expect(artist.featuredOnTitle, equals('Featured Playlists'));
    expect(artist.similarArtistsTitle, equals('Similar Artists'));

    // Lists should be empty because we provided empty contents arrays
    expect(artist.topSongs, isEmpty);
    expect(artist.topAlbums, isEmpty);
    expect(artist.topSingles, isEmpty);
    expect(artist.topVideos, isEmpty);
    expect(artist.featuredOn, isEmpty);
    expect(artist.similarArtists, isEmpty);
  });
}

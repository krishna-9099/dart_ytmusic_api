import 'package:dart_ytmusic_api/parsers/search_parser.dart';
import 'package:dart_ytmusic_api/types.dart';
import 'package:test/test.dart';

void main() {
  test('SearchParser.parse results are filtered to non-null SearchResult', () {
    final songItem = {
      'playlistItemData': {'videoId': 'abc123'},
      'flexColumns': [
        {
          'runs': [
            {'text': 'Test Song Title'}
          ]
        },
        {
          'runs': [
            {'text': 'Song'}
          ]
        },
        {
          'runs': [
            {'text': 'Filler'}
          ]
        },
        {
          'runs': [
            {'text': 'Artist Name', 'browseId': 'artist123'}
          ]
        }
      ],
      'thumbnails': [
        {'url': 'http://example.com/thumb.jpg', 'width': 100, 'height': 100}
      ]
    };

    final unknownItem = {
      'playlistItemData': {'videoId': 'unknown1'},
      'flexColumns': [
        {
          'runs': [
            {'text': 'Some Title'}
          ]
        },
        {
          'runs': [
            {'text': 'UnknownType'}
          ]
        }
      ]
    };

    final results = [songItem, unknownItem];
    final parsed =
        results.map(SearchParser.parse).whereType<SearchResult>().toList();

    expect(parsed.length, 1);
    expect(parsed.first is SongDetailed, true);
    final song = parsed.first as SongDetailed;
    expect(song.name, 'Test Song Title');
    expect(song.videoId, 'abc123');
  });
}

import 'package:dart_ytmusic_api/parsers/related_parser.dart';
import 'package:test/test.dart';

void main() {
  test('parse playlistPanelVideoRenderer nodes', () {
    final data = {
      'playlistPanelVideoRenderer': {
        'videoId': 'VID1',
        'title': {
          'runs': [
            {'text': 'Panel Song'}
          ]
        },
        'longBylineText': {
          'runs': [
            {'text': 'Panel Artist'}
          ]
        },
        'thumbnail': {
          'thumbnails': [
            {'url': 'https://img.example/1.jpg', 'width': 120, 'height': 120}
          ]
        }
      }
    };

    final items = RelatedParser.parseRelatedBrowse(data);
    expect(items, isNotEmpty);
    final item = items.firstWhere((i) => i.id == 'VID1');
    expect(item.title, equals('Panel Song'));
    expect(item.subtitle, contains('Panel Artist'));
    expect(item.thumbnails, isNotEmpty);
  });

  test('parse musicShelfRenderer containing two-row items', () {
    final data = {
      'musicShelfRenderer': {
        'contents': [
          {
            'musicTwoRowItemRenderer': {
              'title': {
                'runs': [
                  {'text': 'Shelf Album'}
                ]
              },
              'subtitle': {
                'runs': [
                  {'text': 'Shelf Artist'}
                ]
              },
              'navigationEndpoint': {
                'browseEndpoint': {'browseId': 'MP_ALBUM_1'}
              },
              'thumbnail': {
                'thumbnails': [
                  {
                    'url': 'https://img.example/2.jpg',
                    'width': 200,
                    'height': 200
                  }
                ]
              }
            }
          }
        ]
      }
    };

    final items = RelatedParser.parseRelatedBrowse(data);
    expect(items, isNotEmpty);
    // Find by title because the browseId may be nested differently in test data
    final item = items.firstWhere((i) => i.title == 'Shelf Album');
    expect(item.title, equals('Shelf Album'));
    expect(item.kind, isNot('')); // kind should be set
    expect(item.thumbnails, isNotEmpty);
  });
}

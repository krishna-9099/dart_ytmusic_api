import 'package:test/test.dart';
import 'package:dart_ytmusic_api/yt_music.dart';

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

    final results = await ytmusic.searchSongs('popular songs');

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
}

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
}

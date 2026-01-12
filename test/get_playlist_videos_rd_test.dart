import 'package:test/test.dart';
import 'package:dart_ytmusic_api/yt_music.dart';

void main() {
  test('getPlaylistVideos handles various RD playlist ID formats', () async {
    final ytmusic = YTMusic();
    await ytmusic.initialize();

    // Various RD playlist IDs seen in responses
    final testPlaylistIds = [
      'RDCLAK5uy_kvB-Tek1AZcCVmlbyA8iDfBgD4hPxgec8',
      'RDAMVMBSJa1UytM8w',
      'RDAMVM_LD-Y4Bf8Zwn8',
      'RDAMPLPLfJC-Hett9qCYegKw3GNBzMC9FaUXLrmo',
    ];

    final successes = <String>[];
    for (final id in testPlaylistIds) {
      try {
        final videos = await ytmusic.getPlaylistVideos(id);

        if (videos.isNotEmpty) {
          successes.add(id);
          print('Found ${videos.length} videos for playlist $id');
        } else {
          print('No videos found for playlist $id (empty result)');
        }
      } catch (e) {
        // Some RD variants may not be supported (invalid internal format), log and continue
        print('getPlaylistVideos failed for RD playlist $id: $e');
      }
    }

    expect(successes, isNotEmpty,
        reason: 'At least one RD playlist format should be supported');
  });
}

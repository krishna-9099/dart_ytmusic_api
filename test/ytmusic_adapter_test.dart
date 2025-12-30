import 'package:test/test.dart';
import 'package:dart_ytmusic_api/infrastructure/ytmusic_adapter.dart';

void main() {
  test('YtMusicAdapter fetchPlaylistMeta returns data for a PL id', () async {
    final adapter = YtMusicAdapter();
    await adapter.initialize();

    // Known working playlist used earlier
    final playlistId = 'PLfJC-Hett9qCYegKw3GNBzMC9FaUXLrmo';

    final playlist = await adapter.fetchPlaylistMeta(playlistId);

    expect(playlist, isNotNull);
    expect(playlist.name, isNotEmpty);
    expect(playlist.videoCount, greaterThan(0));
  }, timeout: Timeout(Duration(minutes: 2)));
}

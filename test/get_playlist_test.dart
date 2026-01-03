import 'package:test/test.dart';
import 'package:dart_ytmusic_api/yt_music.dart';
import 'package:dart_ytmusic_api/types.dart';

void main() {
  test('getPlaylist returns PlaylistFull and expected fields', () async {
    final ytmusic = YTMusic();
    await ytmusic.initialize();

    // Use provided PL playlist ID
    final playlistId = 'PLfJC-Hett9qCYegKw3GNBzMC9FaUXLrmo';
    final PlaylistFull playlist =
        await ytmusic.getPlaylistWithRelated(playlistId);

    expect(playlist, isNotNull);
    expect(playlist.name, isNotEmpty);
    expect(playlist.playlistId, isNotEmpty);
    expect(playlist.videoCount, isA<int>());
    expect(playlist.thumbnails, isNotEmpty);
    expect(playlist.artist, isNotNull);

    print('Playlist name: ${playlist.name}');
    print('Playlist id: ${playlist.playlistId}');
    print('Playlist artist: ${playlist.artist.name}');
    print('Video count: ${playlist.videoCount}');
    print('Thumbnails count: ${playlist.thumbnails.length}');
  });
}

import 'package:test/test.dart';
import 'package:dart_ytmusic_api/yt_music.dart';

void _collectPlaylistIds(dynamic node, Set<String> out) {
  if (node is Map) {
    if (node.containsKey('playlistId')) {
      final id = node['playlistId'];
      if (id is String && id.isNotEmpty) out.add(id);
    }
    for (final v in node.values) {
      _collectPlaylistIds(v, out);
    }
  } else if (node is List) {
    for (final v in node) {
      _collectPlaylistIds(v, out);
    }
  }
}

void main() {
  test('discover related playlist IDs from playlist browse response', () async {
    final ytmusic = YTMusic();
    await ytmusic.initialize();

    final playlistId = 'PLfJC-Hett9qCYegKw3GNBzMC9FaUXLrmo';

    var browseId = playlistId;
    if (browseId.startsWith('PL') || browseId.startsWith('RD')) {
      browseId = 'VL$browseId';
    }

    final data =
        await ytmusic.constructRequest('browse', body: {'browseId': browseId});

    final found = <String>{};
    _collectPlaylistIds(data, found);

    // Remove the main playlist id
    found.remove(playlistId);

    print('Related playlist ids found: ${found.length}');
    for (final id in found) {
      print('- $id');
    }

    // We don't assert existence (may vary by region/session). Ensure traversal didn't throw.
    expect(data, isNotNull);
  });
}

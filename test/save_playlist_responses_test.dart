import 'dart:convert';
import 'dart:io';

import 'package:dart_ytmusic_api/yt_music.dart';
import 'package:dart_ytmusic_api/utils/traverse.dart';
import 'package:test/test.dart';

void main() {
  test('save playlist raw responses', () async {
    final ytmusic = YTMusic();
    await ytmusic.initialize();

    final inputId =
        'RDCLAK5uy_kvB-Tek1AZcCVmlbyA8iDfBgD4hPxgec8'; // change as needed
    final pid = (inputId.startsWith('PL') || inputId.startsWith('RD'))
        ? 'VL$inputId'
        : inputId;

    // Initial browse (raw)
    final raw = await ytmusic.constructRequest('browse', body: {
      'browseId': pid,
      'context': {
        'client': {
          'clientName': 'WEB_REMIX',
          'clientVersion': '1.20251215.03.00'
        }
      }
    });
    final metaOut = File('dart_ytmusic_api/test_output/playlist_raw_meta.json');
    await metaOut.create(recursive: true);
    await metaOut
        .writeAsString(const JsonEncoder.withIndent('  ').convert(raw));

    // Collect playlist item renderers and follow continuations
    final items = <dynamic>[];
    items.addAll(traverseList(raw,
        ['musicPlaylistShelfRenderer', 'musicResponsiveListItemRenderer']));

    dynamic continuation = traverse(raw, ['continuation']);
    if (continuation is List)
      continuation = continuation.isNotEmpty ? continuation[0] : null;

    while (continuation != null && continuation is! List) {
      final page = await ytmusic
          .constructRequest('browse', query: {'continuation': continuation});
      items.addAll(traverseList(page, ['musicResponsiveListItemRenderer']));
      continuation = traverse(page, ['continuation']);
    }

    final itemsOut =
        File('dart_ytmusic_api/test_output/playlist_raw_items.json');
    await itemsOut.create(recursive: true);
    await itemsOut
        .writeAsString(const JsonEncoder.withIndent('  ').convert(items));

    print('Wrote: ${metaOut.path}');
    print('Wrote: ${itemsOut.path}');
  }, timeout: Timeout(Duration(minutes: 2)));
}

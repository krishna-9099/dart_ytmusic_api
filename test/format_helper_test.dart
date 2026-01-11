import 'package:dart_ytmusic_api/format_helper.dart';
import 'package:test/test.dart';

void main() {
  test('resolve direct url', () {
    final format = {'url': 'https://example.com/audio.mp4?expire=4102444800'};

    final res = FormatHelper.resolveFormatUrl(format);
    expect(res.url, isNotNull);
    expect(res.requiresDecipher, isFalse);
    expect(res.expiresAt != null, isTrue);
  });

  test('parse signatureCipher', () {
    final cipher = Uri.encodeQueryComponent(
        'url=https%3A%2F%2Fexample.com%2Faudio.opus%3Fexpire%3D4102444800&sp=sig&s=SIGNATURE');
    // signatureCipher is often not double-encoded, we place raw key=value string
    final format = {
      'signatureCipher':
          'url=https%3A%2F%2Fexample.com%2Faudio.opus%3Fexpire%3D4102444800&sp=sig&s=SIGNATURE'
    };

    final res = FormatHelper.resolveFormatUrl(format);
    expect(res.url, isNull); // requires decipher
    expect(res.requiresDecipher, isTrue);
    expect(res.cipherParams, contains('s'));
    expect(res.cipherParams, contains('url'));
  });

  test('select best audio format prefers opus', () {
    final formats = [
      {
        'itag': 140,
        'mimeType': 'audio/mp4; codecs="mp4a.40.2"',
        'bitrate': 128000
      },
      {'itag': 251, 'mimeType': 'audio/webm; codecs="opus"', 'bitrate': 160000},
    ];

    final choice =
        FormatHelper.selectBestAudioFormat(formats, preferOpus: true);
    expect(choice.mimeType.toLowerCase(), contains('webm'));
    expect(choice.itag, equals(251));
  });
}

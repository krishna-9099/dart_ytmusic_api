import 'package:dart_ytmusic_api/decipher/decipherer.dart';
import 'package:dart_ytmusic_api/format_helper.dart';
import 'package:test/test.dart';

void main() {
  test('tryDecipher returns decoded when registered', () async {
    FormatHelper.registerDecipherer((s) async => 'DECODED:$s');

    final res = await Decipherer.tryDecipher('SIG');
    expect(res, equals('DECODED:SIG'));

    // also ensure FormatHelper.resolveFormatUrl uses it
    final format = {
      'signatureCipher':
          'url=https%3A%2F%2Fexample.com%2Faudio.opus%3Fexpire%3D4102444800&sp=sig&s=SIG'
    };
    final r2 = await FormatHelper.resolveFormatUrl(format);
    expect(r2.url, isNotNull);
    expect(r2.requiresDecipher, isFalse);
    // signature value is URL-encoded when appended
    expect(r2.url, contains('sig=${Uri.encodeComponent('DECODED:SIG')}'));

    // unregister
    FormatHelper.registerDecipherer(null);
  });

  test('tryDecipher returns null on exception or unregistered', () async {
    // register a function that throws
    FormatHelper.registerDecipherer((s) async => throw Exception('fail'));
    final res = await Decipherer.tryDecipher('SIG');
    expect(res, isNull);

    // unregister
    FormatHelper.registerDecipherer(null);
    final res2 = await Decipherer.tryDecipher('SIG');
    expect(res2, isNull);
  });
}

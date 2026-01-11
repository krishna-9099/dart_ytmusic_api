import 'package:dart_ytmusic_api/decipher/player_js_extractor.dart';
import 'package:dart_ytmusic_api/decipher/decipherer.dart';
import 'package:test/test.dart';

void main() {
  test('extract ops from sample player js', () async {
    final js = '''
var Abc = {
  r: function(a){ a.reverse(); },
  s: function(a,b){ a.splice(0,b); },
  w: function(a,b){ var c = a[0]; a[0] = a[b % a.length]; a[b] = c; }
};
function sigFunc(a){ a = a.split(""); Abc.w(a,2); Abc.s(a,3); Abc.r(a); return a.join(""); }
''';

    final ops = PlayerJsExtractor.extractOps(js);
    expect(ops.length, equals(3));
    expect(ops[0]['op'], equals('swap'));
    expect(ops[0]['arg'], equals(2));
    expect(ops[1]['op'], equals('splice'));
    expect(ops[1]['arg'], equals(3));
    expect(ops[2]['op'], equals('reverse'));
  });

  test('build decipher and decode sample signature', () async {
    final js = '''
var Abc = {
  r: function(a){ a.reverse(); },
  s: function(a,b){ a.splice(0,b); },
  w: function(a,b){ var c = a[0]; a[0] = a[b % a.length]; a[b] = c; }
};
function sigFunc(a){ a = a.split(""); Abc.w(a,2); Abc.s(a,3); Abc.r(a); return a.join(""); }
''';
    final fn = await PlayerJsExtractor.buildDecipherFromPlayerJs(js);
    expect(fn, isNotNull);
    final out = await fn!('abcdef');
    // manual calculation: abcdef -> swap(2) => c b a d e f -> splice(3) => d e f -> reverse => f e d
    expect(out, equals('fed'));

    // test registration helper
    final registered = await PlayerJsExtractor.registerDecipherIfFound(js);
    expect(registered, isTrue);
    final res = await Decipherer.tryDecipher('abcdef');
    expect(res, equals('fed'));

    // cleanup
    Decipherer.register(null);
  });

  test('noops on unknown js', () async {
    final js = 'console.log("no signature here");';
    final ops = PlayerJsExtractor.extractOps(js);
    expect(ops, isEmpty);
    final fn = await PlayerJsExtractor.buildDecipherFromPlayerJs(js);
    expect(fn, isNull);
  });
}

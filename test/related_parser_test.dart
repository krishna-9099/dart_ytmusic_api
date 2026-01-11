import 'dart:convert';
import 'dart:io';

import 'package:dart_ytmusic_api/parsers/related_parser.dart';
import 'package:test/test.dart';

void main() {
  test('parse related browse returns non-empty list', () {
    final raw =
        jsonDecode(File('example_related_browse.json').readAsStringSync());
    final items = RelatedParser.parseRelatedBrowse(raw);
    expect(items, isNotEmpty);

    // At least one item should have thumbnails
    expect(items.any((i) => i.thumbnails.isNotEmpty), isTrue,
        reason: 'Expected at least one RelatedItem to include thumbnails');

    // Titles should be present
    expect(items.any((i) => i.title.isNotEmpty), isTrue);

    // At least one song should be present
    expect(items.any((i) => i.kind == 'song'), isTrue);

    // Print a few samples for human verification
    for (var i = 0; i < (items.length < 5 ? items.length : 5); i++) {
      print(items[i]);
    }
  });
}

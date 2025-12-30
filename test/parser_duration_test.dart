import 'package:test/test.dart';
import 'package:dart_ytmusic_api/parsers/parser.dart';

void main() {
  test('parseDurationOrZero returns 0 for null or missing lengthText', () {
    expect(Parser.parseDurationOrZero(null), equals(0));
    expect(Parser.parseDurationOrZero(''), equals(0));
  });

  test('parseDurationOrZero parses common time formats', () {
    expect(Parser.parseDurationOrZero('3:35'), equals(3 * 60 + 35));
    expect(
        Parser.parseDurationOrZero('1:02:15'), equals(1 * 3600 + 2 * 60 + 15));
  });

  test('parseDurationOrZero handles strings with extra text', () {
    // e.g. sometimes strings include extra metadata like "3:45 - Live"
    expect(Parser.parseDurationOrZero('3:45 - Live'), equals(3 * 60 + 45));
    expect(Parser.parseDurationOrZero('Duration: 02:05'), equals(2 * 60 + 5));
  });
}

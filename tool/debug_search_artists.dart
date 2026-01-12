import 'dart:convert';
import 'package:dart_ytmusic_api/yt_music.dart';
import 'package:dart_ytmusic_api/types.dart';
import 'package:dart_ytmusic_api/utils/traverse.dart';

void main() async {
  final yt = YTMusic();
  await yt.initialize();

  print('\n--- Running searchArtists paginated=true for "popular artists" ---');
  final query = 'Arijit Singh';

  final res = await yt.searchArtists(query, paginated: true) as dynamic;

  print('Query: $query');
  print('Type of result: ${res.runtimeType}');
  print('PaginatedResult.items.length: ${res.items.length}');
  print('hasNextPage: ${res.hasNextPage}');
  print('continuationToken: ${res.continuationToken}\n');

  print('Raw search response dump (root keys and sample paths):');
  final raw = await yt.constructRequest('search', body: {
    'query': query,
    'params': 'Eg-KAQwIABAAGAAgASgAMABqChAEEAMQCRAFEAo%3D'
  });

  // Print top-level keys
  print('Top-level keys: ${(raw as Map).keys}\n');

  // Inspect contents deeper
  final contents = raw['contents'];
  print('contents type: ${contents.runtimeType}');
  if (contents is Map) {
    print('contents keys: ${contents.keys}');

    final tabbed = contents['tabbedSearchResultsRenderer'];
    print('tabbedSearchResultsRenderer present: ${tabbed != null}');

    if (tabbed is Map) {
      final tabs = tabbed['tabs'];
      print('tabs length: ${(tabs as List?)?.length}');
      if (tabs is List && tabs.isNotEmpty) {
        final firstTab = tabs[0];
        print('firstTab keys: ${firstTab.keys}');
        final tabContent = firstTab['tabRenderer']?['content'];
        print('firstTab content keys: ${tabContent?.keys}');

        // Try to find musicShelfRenderer or similar inside tab content
        final shelfContents =
            traverseList(tabContent, ['sectionListRenderer', 'contents']);
        print('sectionListRenderer contents length: ${shelfContents.length}');
        if (shelfContents.isNotEmpty) {
          final firstSection = shelfContents[0];
          print('First section keys: ${(firstSection as Map).keys}');

          // Print renderer keys in first section
          for (final k in (firstSection).keys) {
            print('- renderer key: $k');
          }

          final itemSection = firstSection['itemSectionRenderer'];
          print('itemSectionRenderer keys: ${itemSection?.keys}');

          final contentsList = traverseList(itemSection, ['contents']);
          print('itemSectionRenderer.contents length: ${contentsList.length}');

          if (contentsList.isNotEmpty) {
            print(
                'Keys of first content block: ${(contentsList.first as Map).keys}');
            print(
                'First content block sample (pretty): ${jsonEncode(contentsList.first).substring(0, 400)}');
          }
        }
      }
    }
  }

  // Search for artist-like renderers
  for (final k in [
    'musicResponsiveListItemRenderer',
    'musicTwoRowItemRenderer',
    'musicResponsiveListItemFlexColumnRenderer'
  ]) {
    final found = traverseList(raw, [k]);
    print('$k count: ${found.length}');
  }

  // Try to locate artist blocks nested under musicTwoRowItemRenderer
  final twoRow = traverseList(raw, ['musicTwoRowItemRenderer']);
  print('\nSample twoRow count: ${twoRow.length}');
  if (twoRow.isNotEmpty) {
    print('First twoRow keys: ${(twoRow.first as Map).keys}');
  }
}

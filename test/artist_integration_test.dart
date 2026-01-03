import 'package:test/test.dart';
import 'package:dart_ytmusic_api/yt_music.dart';
import 'package:dart_ytmusic_api/types.dart';

void main() {
  test('Fetch real artist and inspect section titles', () async {
    final ytmusic = YTMusic();
    await ytmusic.initialize();

    // Provided test artist ID
    const artistId = 'UCtFOW7jJXChfFNoucRFqRmw';
    final artist = await ytmusic.getArtist(artistId);

    // Basic expectations
    expect(artist, isA<ArtistFull>());
    expect(artist.artistId, equals(artistId));
    expect(artist.name, isNotEmpty);

    // Print the titles parsed by ArtistParser for inspection
    print('topSongsTitle: ${artist.topSongsTitle}');
    print('topAlbumsTitle: ${artist.topAlbumsTitle}');
    print('topSinglesTitle: ${artist.topSinglesTitle}');
    print('topVideosTitle: ${artist.topVideosTitle}');
    print('featuredOnTitle: ${artist.featuredOnTitle}');
    print('similarArtistsTitle: ${artist.similarArtistsTitle}');

    // Ensure at least one of the title fields is present to confirm parsing
    final hasAnyTitle = [
      artist.topSongsTitle,
      artist.topAlbumsTitle,
      artist.topSinglesTitle,
      artist.topVideosTitle,
      artist.featuredOnTitle,
      artist.similarArtistsTitle,
    ].any((t) => t != null && t.isNotEmpty);

    expect(hasAnyTitle, isTrue,
        reason: 'Expected at least one parsed section title from artist page');
  }, timeout: Timeout(Duration(seconds: 30)));
}

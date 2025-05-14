## 1.2.1

**Fix**
- Removed exit(1)

## 1.2.0

**New Feature**
- Added ytMusicHomeRawHtml property to add credentials externally

## 1.1.1

**Fixes**
- Fix exeption when timed lyrics is not found

## 1.1.0

**New Feature**
- getTimedLyrics(String videoId): New method to retrieve timed lyrics for a song. This allows developers to access lyrics synchronized with audio playback times.

## 1.0.8
**Fixes**
- Fix search method: fixed search method returns empty results.

## 1.0.7

- **Fixes**
- Some songs were not found.

## 1.0.6

**Fixes**
- Fixed song duration handler

## 1.0.5

**Fixes**
- Fixed albumParser: Fixed bad element when ids array is empty.
- Fixed artistPaser: Fixed filters to prevent return items where albumId is empty.
- Fixed songParser: Fixed duration parser.

## 1.0.4

- Fixed no songs in some albums

## 1.0.3

- Fixed album songs

## 1.0.2

- Return artist songs instead of album songs in getAlbum to increase lyrics search.

## 1.0.0

- Initial version.

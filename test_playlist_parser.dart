import 'dart:convert';
import 'dart:io';
import 'package:dart_ytmusic_api/parsers/playlist_parser.dart';

void main() async {
  // Load the JSON file
  final file = File('test_output/playlist_raw_meta.json');
  if (!await file.exists()) {
    print('JSON file not found');
    return;
  }

  final jsonString = await file.readAsString();
  final data = json.decode(jsonString);

  // Parse the playlist
  const playlistId = 'PL5AQcqOVm-2wNMW35cT24ar0xY4IPeTmw';
  final playlist = PlaylistParser.parse(data, playlistId);

  // Print the results
  print('Playlist Name: ${playlist.name}');
  print('Year: ${playlist.year}');
  print('View Count: ${playlist.viewCount}');
  print('Video Count: ${playlist.videoCount}');
  print('Artist: ${playlist.artist.name}');
}

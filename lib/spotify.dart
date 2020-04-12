import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:ind/database_helpers.dart';
import 'package:spotify/spotify.dart';
import 'package:android_intent/android_intent.dart';
import 'package:flutter_package_manager/flutter_package_manager.dart';

Future<List> getSpotifyApi(String id) async {
  final credentials = SpotifyApiCredentials(
      "1f5872b3b48c406591ca52118a3e7901", "5a81df5a49a34f3e990e7ba2a80e5f8b");
  var spotify = SpotifyApi(credentials);

  try {
    var track = await spotify.tracks.list([id]);
    List a = [track.first.name, track.first.artists.first.name];
    return a;
//    track.forEach((x) {
//      print(x.name);
//      x.artists.forEach((y) {
//        print(y.name);
//      });
//    });
  } catch (e) {
    try {
      var artists = await spotify.artists.list([id]);
      return [artists.first.name, "Artista"];
//      artists.forEach((x) => print(x.name));
    } catch (e) {
      try {
        var album = await spotify.albums.get(id);
        return [album.name, album.artists.first.name];
      } catch (e) {
        print('error');
      }
    }
  }
}

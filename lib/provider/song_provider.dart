import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SongProvider extends ChangeNotifier {
  List<Map<String, dynamic>> songs = [];
  List<Map<String, dynamic>> favoriteSongs = [];

  // Load songs from JSON
  Future<void> loadSongs() async {
    final String response = await rootBundle.loadString('assets/songs.json');
    final data = await json.decode(response);
    songs = List<Map<String, dynamic>>.from(data['results']);
    notifyListeners();
  }

  // Add to favorites
  void addFavorite(Map<String, dynamic> song) {
    if (!favoriteSongs.contains(song)) {
      favoriteSongs.add(song);
      notifyListeners();
    }
  }

  // Remove from favorites
  void removeFavorite(Map<String, dynamic> song) {
    favoriteSongs.remove(song);
    notifyListeners();
  }

  // Toggle favorite (optional)
  void toggleFavorite(Map<String, dynamic> song) {
    if (favoriteSongs.contains(song)) {
      removeFavorite(song);
    } else {
      addFavorite(song);
    }
  }

  // Check if a song is favorite
  bool isFavorite(Map<String, dynamic> song) {
    return favoriteSongs.contains(song);
  }
}

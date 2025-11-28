import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SongProvider extends ChangeNotifier {
  List<Map<String, dynamic>> songs = [];
  List<Map<String, dynamic>> allSongs = []; // For search
  List<Map<String, dynamic>> favoriteSongs = [];

  bool isLoading = false;
  bool isLoadingMore = false;
  bool isError = false;
  String errorMessage = '';

  int itemsPerPage = 20;
  int currentPage = 1;

  SongProvider() {
    loadFavoritesFromPrefs();
  }

  // -------------------------
  // LOAD SONGS
  // -------------------------
  Future<void> loadSongs() async {
    try {
      isLoading = true;
      isError = false;
      notifyListeners();

      final String response = await rootBundle.loadString('assets/songs.json');
      final data = json.decode(response);

      if (data == null || data['results'] == null) {
        throw Exception("Invalid JSON format: 'results' not found.");
      }

      allSongs = List<Map<String, dynamic>>.from(data['results']);

      // Load only first page initially
      songs = allSongs.take(itemsPerPage).toList();
      currentPage = 1;

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      isError = true;
      errorMessage = "Failed to load songs!";
      notifyListeners();
    }
  }

  // -------------------------
  // SEARCH SONGS
  // -------------------------
  void searchSongs(String query) {
    if (query.isEmpty) {
      songs = allSongs.take(itemsPerPage).toList();
    } else {
      songs = allSongs
          .where(
            (song) =>
                song['trackName'].toString().toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                song['artistName'].toString().toLowerCase().contains(
                  query.toLowerCase(),
                ),
          )
          .toList();
    }
    notifyListeners();
  }

  // -------------------------
  // LOAD MORE SONGS
  // -------------------------
  Future<void> loadMoreSongs() async {
    if (isLoadingMore) return;

    isLoadingMore = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    currentPage++;
    int newLimit = currentPage * itemsPerPage;

    if (newLimit < allSongs.length) {
      songs = allSongs.take(newLimit).toList();
    }

    isLoadingMore = false;
    notifyListeners();
  }

  // -------------------------
  // FAVORITES WITH SHARED PREFERENCES
  // -------------------------
  void addFavorite(Map<String, dynamic> song) {
    if (!isFavorite(song)) {
      favoriteSongs.add(song);
      saveFavoritesToPrefs();
      notifyListeners();
    }
  }

  void removeFavorite(Map<String, dynamic> song) {
    favoriteSongs.removeWhere((s) => s['trackId'] == song['trackId']);
    saveFavoritesToPrefs();
    notifyListeners();
  }

  void toggleFavorite(Map<String, dynamic> song) {
    if (isFavorite(song)) {
      removeFavorite(song);
    } else {
      addFavorite(song);
    }
  }

  bool isFavorite(Map<String, dynamic> song) {
    return favoriteSongs.any((s) => s['trackId'] == song['trackId']);
  }

  // -------------------------
  // SHARED PREFERENCES FUNCTIONS
  // -------------------------
  Future<void> saveFavoritesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favStringList = favoriteSongs
        .map((song) => jsonEncode(song))
        .toList();
    await prefs.setStringList('favorite_songs', favStringList);
  }

  Future<void> loadFavoritesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final favStringList = prefs.getStringList('favorite_songs') ?? [];
    favoriteSongs = favStringList
        .map((song) => jsonDecode(song))
        .toList()
        .cast<Map<String, dynamic>>();
    notifyListeners();
  }
}

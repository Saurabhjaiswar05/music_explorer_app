import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_explorer_app/provider/song_provider.dart';
import 'package:music_explorer_app/pages/song_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);
    final favoriteSongs = songProvider.favoriteSongs;

    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Songs')),
      body: favoriteSongs.isEmpty
          ? const Center(
              child: Text(
                'No favorite songs yet!',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: favoriteSongs.length,
              itemBuilder: (context, index) {
                final song = favoriteSongs[index];
                return ListTile(
                  leading: Image.network(song['artworkUrl60']),
                  title: Text(song['trackName']),
                  subtitle: Text(song['artistName']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      songProvider.removeFavorite(song);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SongDetailPage(song: song, isFavorite: true),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
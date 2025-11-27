import 'package:flutter/material.dart';
import 'package:music_explorer_app/pages/song_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:music_explorer_app/provider/song_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load songs when HomePage is initialized
    Provider.of<SongProvider>(context, listen: false).loadSongs();
  }

  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Music Explorer App')),
      body: songProvider.songs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: songProvider.songs.length,
              itemBuilder: (context, index) {
                final song = songProvider.songs[index];
                return ListTile(
                  leading: Image.network(song['artworkUrl60']),
                  title: Text(song['trackName']),
                  subtitle: Text(song['artistName']),
                  trailing: Text(song['trackPrice'].toString() + ' USD'),
                  onTap: () {
                    // You can handle song tap here (play preview etc.)
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SongDetailPage(song: song,)));
                  },
                );
              },
            ),
    );
  }
}

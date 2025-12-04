import 'package:flutter/material.dart';
import 'package:music_explorer_app/pages/Favorites_page.dart';
import 'package:music_explorer_app/pages/song_detail_page.dart';
import 'package:music_explorer_app/provider/theme_provider.dart';
import 'package:music_explorer_app/services/songs_api_services.dart';
import 'package:provider/provider.dart';
import 'package:music_explorer_app/provider/song_provider.dart';
import 'package:music_explorer_app/theme/app_theme.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool isLoadingShimmer = true;

  List<Map<String, dynamic>> allsongsList = [];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SongProvider>(context, listen: false);
    provider.loadSongs();
    // getAllSongs();

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => isLoadingShimmer = false);
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        provider.loadMoreSongs();
      }
    });
  }

  Future<void> getAllSongs() async {
    try {
      final response = await SongsApiServices().getAllSongs();
      print("only result : ${response['results']}");
      setState(() {
        allsongsList = response['results'];
      });
    } catch (e) {
      print(e);
    }
  }

  Widget _shimmerList() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
      itemCount: 6,
      itemBuilder: (_, __) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.small),
          child: Shimmer.fromColors(
            baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
            highlightColor: isDark
                ? Colors.grey.shade700
                : Colors.grey.shade100,
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        color: isDark ? Colors.grey[900] : Colors.white,
                        margin: const EdgeInsets.only(
                          bottom: AppSpacing.xsmall,
                        ),
                      ),
                      Container(
                        height: 14,
                        width: 100,
                        color: isDark ? Colors.grey[900] : Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : AppColors.primary,
        title: Text(
          'Music Explorer App',
          style: TextStyle(color: isDark ? Colors.white : Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.white : Colors.white,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),

          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.pinkAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: TextField(
              controller: _searchController,
              onChanged: songProvider.searchSongs,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black,
              ),

              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.white,
                hintText: "Search songs...",
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child:
                (isLoadingShimmer ||
                    (songProvider.isLoading && songProvider.songs.isEmpty))
                ? _shimmerList()
                : songProvider.isError
                ? Center(
                    child: Text(
                      songProvider.errorMessage,
                      style: TextStyle(fontSize: 16, color: AppColors.error),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.medium,
                    ),
                    itemCount:
                        songProvider.songs.length +
                        (songProvider.isLoadingMore ? 1 : 0),

                    itemBuilder: (context, index) {
                      if (index == songProvider.songs.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.medium),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }

                      final song = songProvider.songs[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: AppSpacing.small,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            if (!isDark)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(
                            AppSpacing.small,
                          ),

                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              song['artworkUrl100'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),

                          title: Text(
                            song['trackName'],
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                song['artistName'],
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),

                              Text(
                                "Release Date : ${song['releaseDate']}",
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),

                              Text(
                                "GenreName :${song['primaryGenreName']}",
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),

                          trailing: Icon(
                            Icons.chevron_right,
                            color: isDark ? Colors.white : AppColors.primary,
                          ),

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SongDetailPage(song: song),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

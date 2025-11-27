import 'package:flutter/material.dart';
import 'package:music_explorer_app/pages/Favorites_page.dart';
import 'package:music_explorer_app/pages/song_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:music_explorer_app/provider/song_provider.dart';
import 'package:music_explorer_app/theme/app_theme.dart';
import 'package:shimmer/shimmer.dart'; // ← shimmer added

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool isLoadingShimmer = true; // shimmer flag

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<SongProvider>(context, listen: false);
    provider.loadSongs();

    // Keep shimmer visible for 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          isLoadingShimmer = false;
        });
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        provider.loadMoreSongs();
      }
    });
  }

  /// Shimmer effect list
  Widget _shimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
      itemCount: 6,
      itemBuilder: (_, __) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.small),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                        color: Colors.white,
                        margin: const EdgeInsets.only(
                          bottom: AppSpacing.xsmall,
                        ),
                      ),
                      Container(height: 14, width: 100, color: Colors.white),
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Music Explorer App',
          style: TextStyle(color: AppColors.background),
        ),
        actions: [
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
          // ---------------- SEARCH BAR ----------------
          Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => songProvider.searchSongs(value),
              style: AppTextStyles.titleMedium.copyWith(fontSize: 16),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Search songs...",
                hintStyle: AppTextStyles.smallText,
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.small,
                ),
              ),
            ),
          ),

          // ---------------- SONG LIST ----------------
          Expanded(
            child:
                (isLoadingShimmer ||
                    (songProvider.isLoading && songProvider.songs.isEmpty))
                ? _shimmerList() // show shimmer
                : songProvider.isError
                ? Center(
                    child: Text(
                      songProvider.errorMessage,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 16,
                        color: AppColors.error,
                      ),
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
                        return const Padding(
                          padding: EdgeInsets.all(AppSpacing.medium),
                          child: Center(
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
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
                            style: AppTextStyles.titleMedium.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            song['artistName'],
                            style: AppTextStyles.smallText,
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.primary,
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

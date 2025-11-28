import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:music_explorer_app/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:music_explorer_app/provider/song_provider.dart';
import 'package:music_explorer_app/pages/song_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => isLoading = true);

    final songProvider = Provider.of<SongProvider>(context, listen: false);
    await songProvider.loadFavoritesFromPrefs();

    await Future.delayed(const Duration(seconds: 1));
    setState(() => isLoading = false);
  }

  Widget _shimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.medium),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.medium,
        mainAxisSpacing: AppSpacing.medium,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        Color base = Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.grey.shade300;

        Color highlight = Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade700
            : Colors.grey.shade100;

        return Shimmer.fromColors(
          baseColor: base,
          highlightColor: highlight,
          child: Container(
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);
    final favoriteSongs = songProvider.favoriteSongs;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyMedium!.color;

    return Scaffold(
      backgroundColor: isDark
          ? const Color.fromARGB(255, 54, 51, 51)
          : AppColors.backgroundLight,

      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : AppColors.primary,

        title: const Text(
          'Favorite Songs',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: isLoading
          ? _shimmerGrid()
          : favoriteSongs.isEmpty
          ? const Center(
              child: Text(
                'No favorite songs yet!',
                style: TextStyle(fontSize: 18),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: GridView.builder(
                itemCount: favoriteSongs.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.medium,
                  mainAxisSpacing: AppSpacing.medium,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final song = favoriteSongs[index];

                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SongDetailPage(song: song, isFavorite: true),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(AppSpacing.small),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  song['artworkUrl100'],
                                  width: double.infinity,
                                  height: 155,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.small),
                              Text(
                                song['trackName'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: textColor,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xsmall),
                              Text(
                                song['artistName'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.smallText.copyWith(
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ❌ Remove Favorite Icon
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              songProvider.removeFavorite(song);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../provider/song_provider.dart';
import '../theme/app_theme.dart';

class SongDetailPage extends StatefulWidget {
  final Map<String, dynamic> song;
  bool? isFavorite;

  SongDetailPage({super.key, required this.song, this.isFavorite});

  @override
  State<SongDetailPage> createState() => _SongDetailPageState();
}

class _SongDetailPageState extends State<SongDetailPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Timer? _previewTimer;
  bool isLoadingShimmer = true;

  @override
  void initState() {
    super.initState();

    // Show shimmer for 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          isLoadingShimmer = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Play / Pause preview audio (stop after 30 seconds)
  void _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _previewTimer?.cancel();
    } else {
      await _audioPlayer.play(UrlSource(widget.song['previewUrl']));

      _previewTimer?.cancel();
      _previewTimer = Timer(const Duration(seconds: 30), () async {
        await _audioPlayer.stop();
        setState(() {
          _isPlaying = false;
        });
      });
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  Widget _shimmerContent() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: AppSpacing.xlarge * 1.5),
          Container(height: 24, width: 200, color: Colors.white),
          const SizedBox(height: AppSpacing.small),
          Container(height: 16, width: 150, color: Colors.white),
          const SizedBox(height: AppSpacing.xsmall),
          Container(height: 14, width: 120, color: Colors.white),
          const SizedBox(height: AppSpacing.xlarge * 1.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(height: 40, width: 120, color: Colors.white),
              const SizedBox(width: AppSpacing.small),
              Container(height: 40, width: 120, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);
    final isFavorite = songProvider.isFavorite(widget.song);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.song['trackName'],
          style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: isLoadingShimmer
            ? _shimmerContent()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// Album Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      widget.song['artworkUrl100'],
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xlarge * 1.5),

                  /// Song Name
                  Text(
                    widget.song['trackName'],
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.small),

                  /// Artist Name
                  Text(
                    widget.song['artistName'],
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: AppSpacing.xsmall),

                  /// Album Name
                  Text(
                    widget.song['collectionName'],
                    style: AppTextStyles.smallText,
                  ),
                  const SizedBox(height: AppSpacing.xlarge * 1.5),

                  /// Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// Play / Pause Preview Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.small,
                            vertical: AppSpacing.medium,
                          ),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: AppTextStyles.buttonText.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: _togglePlay,
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        label: Text(
                          _isPlaying ? 'Pause Preview' : 'Play Preview',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),

                      const SizedBox(width: AppSpacing.small),

                      /// Favorite Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.small,
                            vertical: AppSpacing.medium,
                          ),
                          backgroundColor: isFavorite
                              ? AppColors.favorite
                              : AppColors.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: AppTextStyles.buttonText.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          songProvider.toggleFavorite(widget.song);
                          setState(() {}); // Refresh UI immediately
                        },
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                        ),
                        label: Text(
                          isFavorite ? 'Remove Favorite' : 'Add Favorite',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

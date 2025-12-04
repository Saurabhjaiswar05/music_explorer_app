import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../provider/song_provider.dart';
import '../provider/theme_provider.dart';
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
  Duration _totalDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;

  @override
  void initState() {
    super.initState();

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.resume();
      setState(() {
        _isPlaying = false;
        _currentPosition = Duration.zero;
      });
    });

    Future.delayed(const Duration(seconds: 1), () async {
      if (mounted) {
        setState(() => isLoadingShimmer = false);
      }

      /// 🚀 AUTO-PLAY SONG AFTER SHIMMER
      await _audioPlayer.play(UrlSource(widget.song['previewUrl']));
      setState(() => _isPlaying = true);
    });
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Play / Pause preview audio for 30 seconds
  void _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _previewTimer?.cancel();
    } else {
      await _audioPlayer.play(UrlSource(widget.song['previewUrl']));

      _previewTimer?.cancel();
      _previewTimer = Timer(const Duration(seconds: 30), () async {
        await _audioPlayer.stop();
        setState(() => _isPlaying = false);
      });
    }

    setState(() => _isPlaying = !_isPlaying);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget _shimmerContent(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Shimmer.fromColors(
      baseColor: Colors.grey.shade500,
      highlightColor: Colors.grey.shade500,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final isFavorite = songProvider.isFavorite(widget.song);

    return Scaffold(
      backgroundColor: isDark
          ? const Color.fromARGB(255, 54, 51, 51)
          : AppColors.backgroundLight,

      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : AppColors.primary,
        title: Text(
          widget.song['trackName'],
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: isLoadingShimmer
            ? _shimmerContent(context)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// ================= ALBUM IMAGE =================
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      widget.song['artworkUrl100'],
                      width: double.infinity,
                      height: 350,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xlarge),

                  /// ================= SONG NAME =================
                  Text(
                    widget.song['trackName'],
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: isDark ? AppColors.textWhite : AppColors.textDark,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.small),

                  /// ================= ARTIST NAME =================
                  Text(
                    widget.song['artistName'],
                    style: AppTextStyles.subtitle.copyWith(
                      color: isDark ? Colors.white70 : AppColors.textLight,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xsmall),

                  /// ================= ALBUM NAME =================
                  Text(
                    widget.song['collectionName'],
                    style: AppTextStyles.smallText.copyWith(
                      color: isDark ? Colors.white60 : AppColors.textLight,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.medium),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? AppColors.favorite
                                : Colors.grey,
                            size: 45,
                          ),
                          onPressed: () {
                            songProvider.toggleFavorite(widget.song);
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 5),
                  // Slider + time
                  Column(
                    children: [
                      Slider(
                        min: 0,
                        max: _totalDuration.inSeconds.toDouble(),
                        value: _currentPosition.inSeconds.toDouble().clamp(
                          0,
                          _totalDuration.inSeconds.toDouble(),
                        ),
                        onChanged: (value) async {
                          final position = Duration(seconds: value.toInt());
                          await _audioPlayer.seek(position);
                          setState(() {
                            _currentPosition = position;
                          });
                        },
                        activeColor: AppColors.primary,
                        inactiveColor: isDark
                            ? Colors.white38
                            : Colors.grey[300],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.small,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_currentPosition),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              _formatDuration(_totalDuration),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// ================= AUDIO CONTROLS (BACK - PLAY - FORWARD) ================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ⏪ BACK 5 SEC
                          IconButton(
                            icon: const Icon(Icons.fast_rewind, size: 36),
                            color: isDark ? Colors.white : Colors.black,
                            onPressed: () async {
                              final newPosition =
                                  _currentPosition - const Duration(seconds: 5);
                              await _audioPlayer.seek(
                                newPosition > Duration.zero
                                    ? newPosition
                                    : Duration.zero,
                              );
                            },
                          ),

                          const SizedBox(width: 20),

                          // ⏯ PLAY / PAUSE
                          IconButton(
                            icon: Icon(
                              _isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                              size: 55,
                            ),
                            color: AppColors.primary,
                            onPressed: _togglePlay,
                          ),

                          const SizedBox(width: 20),

                          // ⏩ FORWARD 5 SEC
                          IconButton(
                            icon: const Icon(Icons.fast_forward, size: 36),
                            color: isDark ? Colors.white : Colors.black,
                            onPressed: () async {
                              final newPosition =
                                  _currentPosition + const Duration(seconds: 5);
                              if (newPosition < _totalDuration) {
                                await _audioPlayer.seek(newPosition);
                              } else {
                                await _audioPlayer.seek(_totalDuration);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xlarge * 1.5),
                ],
              ),
      ),
    );
  }
}

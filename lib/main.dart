import 'package:flutter/material.dart';
import 'package:music_explorer_app/pages/home_page.dart';
import 'package:music_explorer_app/provider/song_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SongProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Explorer App',
      home: const HomePage(),
    );
  }
}

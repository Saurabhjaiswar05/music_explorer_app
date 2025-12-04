import 'package:flutter/material.dart';
import 'package:music_explorer_app/pages/home_page.dart';
import 'package:music_explorer_app/provider/song_provider.dart';
import 'package:music_explorer_app/provider/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SongProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Explorer App',
      theme: ThemeData.light(),  
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.currentTheme,
      home: const HomePage(),
    );
  }
}
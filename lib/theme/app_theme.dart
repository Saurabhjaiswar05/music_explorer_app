import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF3F3D56);

  // Light mode
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF1B1B1B);

  // Dark mode
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color textWhite = Colors.white;

  static const Color textLight = Color(0xFF6E6E6E);
  static const Color error = Color(0xFFE63946);
  static const Color favorite = Colors.red;
}

class AppTextStyles {
  static const TextStyle titleLarge = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle subtitle = TextStyle(fontSize: 18);

  static const TextStyle smallText = TextStyle(fontSize: 14);

  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

class AppSpacing {
  static const double xsmall = 4;
  static const double small = 8;
  static const double medium = 16;
  static const double large = 24;
  static const double xlarge = 32;
}

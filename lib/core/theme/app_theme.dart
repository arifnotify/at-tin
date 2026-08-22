import 'package:flutter/material.dart';

class AppTheme {

  static ThemeData lightTheme =
      ThemeData(
    useMaterial3: true,

    colorScheme:
        ColorScheme.fromSeed(
      seedColor:
          const Color.fromARGB(255, 7, 161, 20),
    ),
  );
}
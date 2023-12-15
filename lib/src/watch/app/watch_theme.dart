import 'package:flutter/material.dart';

abstract base class WatchTheme {
  static const seedColor = Colors.purple;

  static final theme = ThemeData.from(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ),
  );
}

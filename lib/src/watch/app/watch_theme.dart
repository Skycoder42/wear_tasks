import 'package:flutter/material.dart';

abstract base class WatchTheme {
  static const seedColor = Colors.purple;

  static final theme = ThemeData.from(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      background: Colors.black,
    ),
  ).apply(
    (t) => t.copyWith(
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    ),
  );
}

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
}

extension on ThemeData {
  ThemeData apply(ThemeData Function(ThemeData t) callback) => callback(this);
}

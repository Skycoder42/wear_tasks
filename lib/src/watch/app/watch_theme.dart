import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'watch_theme.g.dart';

@Riverpod(keepAlive: true)
ThemeData watchTheme(WatchThemeRef ref, Color color) =>
    WatchTheme.createThemeForColor(color);

abstract base class WatchTheme {
  static const appColor = Color(0xFF673ab7);

  static ThemeData createThemeForColor(Color color) => ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: color,
          brightness: Brightness.dark,
          background: Colors.black,
        ),
      ).apply(
        (t) => t.copyWith(
          listTileTheme: const ListTileThemeData(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            dense: true,
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

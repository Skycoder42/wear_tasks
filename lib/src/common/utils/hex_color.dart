import 'dart:ui';

class HexColor extends Color {
  HexColor._(super.value);

  factory HexColor.parse(String hexColor) {
    final rawColor = switch (hexColor.replaceFirst('#', '')) {
      final String s when s.length == 3 =>
        'FF${s[0] * 2}${s[1] * 2}${s[2] * 2}',
      final String s when s.length == 4 =>
        '${s[3] * 2}${s[0] * 2}${s[1] * 2}${s[2] * 2}',
      final String s when s.length == 6 => 'FF$s',
      final String s when s.length == 8 =>
        '${s.substring(6)}${s.substring(0, 6)}',
      _ => throw ArgumentError.value(
          hexColor,
          'hexColor',
          'Not a valid hex color code',
        ),
    };
    return HexColor._(int.parse(rawColor, radix: 16));
  }
}

extension HexColorX on Color {
  String toHexString({bool? withAlpha}) {
    final buffer = StringBuffer('#')
      ..write(_toHex(red))
      ..write(_toHex(green))
      ..write(_toHex(blue));
    if (withAlpha ?? opacity < 1.0) {
      buffer.write(_toHex(alpha));
    }
    return buffer.toString();
  }

  static String _toHex(int value) => value.toRadixString(16).padLeft(2, '0');
}

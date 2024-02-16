import 'dart:io';
import 'dart:math';

import 'package:dart_test_tools/tools.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

Future<void> main() => Github.runZoned(() async {
      final pubspecFile = File('pubspec.yaml');
      final pubspec = Pubspec.parse(
        await pubspecFile.readAsString(),
        sourceUrl: pubspecFile.uri,
      );

      Github.logInfo('Detected app version as ${pubspec.version}');
      final Version(major: major, minor: minor, patch: patch) =
          pubspec.version!;

      final buildNumber =
          _padFilled(major, 0) + _padFilled(minor, 2) + _padFilled(patch, 2);

      Github.logInfo('Generated build number as $buildNumber');

      await Github.env.setOutput('buildNumber', buildNumber);
    });

String _padFilled(int number, int width) {
  if (width > 0 && number >= pow(10, width)) {
    throw StateError(
      'Version number does not fit! '
      'Segment $number has more then $width digits',
    );
  }
  return number.toRadixString(10).padLeft(width, '0');
}

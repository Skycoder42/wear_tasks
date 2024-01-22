// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'src/common/setup.dart';
import 'src/watch/app/watch_app.dart';
import 'src/watch/app/watch_provider_scope.dart';

void main() {
  if (!kDebugMode) {
    FlutterNativeSplash.preserve(
      widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
    );
  }

  setup();

  // ignore: missing_provider_scope
  runApp(
    const WatchProviderScope(
      child: WatchApp(),
    ),
  );
}

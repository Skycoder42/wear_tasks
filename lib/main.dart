// ignore_for_file: avoid_print

import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:logging/logging.dart';

import 'src/watch/app/watch_app.dart';
import 'src/watch/app/watch_provider_scope.dart';

void main() {
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen((event) {
      print(event);
      if (event.error != null) {
        print(event.error);
      }
      if (event.stackTrace != null) {
        print(event.stackTrace);
      }
    });

  if (!kDebugMode) {
    FlutterNativeSplash.preserve(
      widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
    );
  }

  EtebaseFlutter().configure(logLevel: Level.ALL.value);

  // ignore: missing_provider_scope
  runApp(
    const WatchProviderScope(
      child: WatchApp(),
    ),
  );
}

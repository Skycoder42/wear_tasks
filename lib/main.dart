// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import 'src/watch/app/watch_app.dart';

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

  runApp(
    const ProviderScope(
      child: WatchApp(),
    ),
  );
}

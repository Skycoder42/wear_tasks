// ignore_for_file: avoid_print

import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:logging/logging.dart';

void setup() {
  _setupLogger();
}

void _setupLogger() {
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

  EtebaseFlutter().configure(logLevel: Level.ALL.value);
}

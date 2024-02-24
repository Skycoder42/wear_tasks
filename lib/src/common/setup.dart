import 'dart:async';
import 'dart:developer';

import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_logging/sentry_logging.dart';

abstract base class Setup {
  static const _hasSentryDsn = bool.hasEnvironment('SENTRY_DSN');

  const Setup._();

  static FutureOr<void> run(
    AppRunner appRunner, [
    FlutterOptionsConfiguration extraConfig = _noOpExtra,
  ]) {
    if (_hasSentryDsn) {
      return SentryFlutter.init(
        (options) => extraConfig(
          options
            ..attachThreads = true
            ..anrEnabled = true
            ..autoAppStart = false
            ..attachViewHierarchy = true
            ..addIntegration(LoggingIntegration()),
        ),
        appRunner: () => _setupAndRun(appRunner),
      );
    } else {
      if (kDebugMode) {
        Logger.root
          ..level = Level.ALL
          ..onRecord.listen(
            (event) => log(
              event.message,
              time: event.time,
              sequenceNumber: event.sequenceNumber,
              level: event.level.value,
              name: event.loggerName,
              zone: event.zone,
              error: event.error,
              stackTrace: event.stackTrace,
            ),
          );
      }

      return _setupAndRun(appRunner);
    }
  }

  static FutureOr<void> _setupAndRun(AppRunner appRunner) {
    EtebaseFlutter().configure(
      logLevel: kDebugMode ? Level.ALL.value : null,
    );

    return appRunner();
  }

  static void _noOpExtra(SentryFlutterOptions config) {}
}

import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_logging/sentry_logging.dart';

const sentryDsn =
    'https://a435fd2d17c24b6d17680cf73257e7ae@o4506750007115776.ingest.sentry.io/4506750008360960';

abstract base class Setup {
  const Setup._();

  static Future<void> run(
    AppRunner appRunner, [
    FlutterOptionsConfiguration extraConfig = _noOpExtra,
  ]) =>
      SentryFlutter.init(
        (options) => extraConfig(
          options
            ..debug = kDebugMode
            ..dsn = sentryDsn
            ..attachThreads = true
            ..anrEnabled = true
            ..autoAppStart = false
            ..attachViewHierarchy = true
            ..addIntegration(LoggingIntegration()),
        ),
        appRunner: () {
          EtebaseFlutter().configure(
            logLevel: kDebugMode ? Level.ALL.value : null,
          );

          return appRunner();
        },
      );

  static void _noOpExtra(SentryFlutterOptions config) {}
}

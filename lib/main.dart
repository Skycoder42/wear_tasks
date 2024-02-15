// ignore_for_file: avoid_print, unused_import

import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_logging/sentry_logging.dart';

import 'src/common/setup.dart';
import 'src/watch/app/watch_app.dart';
import 'src/watch/app/watch_provider_scope.dart';

Future<void> main() async {
  if (!kDebugMode) {
    FlutterNativeSplash.preserve(
      widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
    );
  }

  await Setup.run(_appRunner);
}

// ignore: missing_provider_scope
void _appRunner() => runApp(
      DefaultAssetBundle(
        bundle: SentryAssetBundle(),
        child: const WatchProviderScope(
          child: WatchApp(),
        ),
      ),
    );

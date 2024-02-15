import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'startup_observer.g.dart';

@riverpod
StartupObserver startupObserver(StartupObserverRef ref) => StartupObserver();

class StartupObserver extends NavigatorObserver {
  bool wasInitialized = false;

  @override
  void didPush(Route route, Route? previousRoute) {
    if (!wasInitialized) {
      wasInitialized = true;
      FlutterNativeSplash.remove();
      SentryFlutter.setAppStartEnd(DateTime.now());
    }
  }
}

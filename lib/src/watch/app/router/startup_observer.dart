import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'startup_observer.g.dart';

@riverpod
StartupObserver startupObserver(StartupObserverRef ref) => StartupObserver();

class StartupObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    FlutterNativeSplash.remove();
  }
}

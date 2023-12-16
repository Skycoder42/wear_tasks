import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../pages/login/login_page.dart';

part 'watch_router.g.dart';

@riverpod
GoRouter watchRouter(WatchRouterRef ref) => GoRouter(
      routes: $appRoutes,
      redirect: _globalRedirect,
    );

FutureOr<String?> _globalRedirect(BuildContext context, GoRouterState state) {
  if (!(state.fullPath?.startsWith(const LoginRoute().location) ?? false)) {
    return LoginRoute(redirectTo: state.fullPath).location;
  }

  return null;
}

@TypedGoRoute<HomeRoute>(path: '/')
@immutable
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const Scaffold(body: Placeholder());
}

@TypedGoRoute<LoginRoute>(path: '/login')
@immutable
class LoginRoute extends GoRouteData {
  final String? redirectTo;

  const LoginRoute({
    this.redirectTo,
  });

  @override
  Widget build(BuildContext context, GoRouterState state) => LoginPage(
        redirectTo: redirectTo,
      );
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../pages/create_task/create_reminder_page.dart';
import '../../pages/home/home_page.dart';
import '../../pages/login/login_page.dart';
import 'global_resolver.dart';
import 'startup_observer.dart';

part 'watch_router.g.dart';

@riverpod
GoRouter watchRouter(WatchRouterRef ref) => GoRouter(
      routes: $appRoutes,
      observers: [
        ref.watch(startupObserverProvider),
      ],
      redirect: ref.watch(globalResolverProvider).call,
    );

@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: [
    TypedGoRoute<CreateTaskRoute>(path: 'tasks/create'),
  ],
)
@immutable
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}

@immutable
class CreateTaskRoute extends GoRouteData {
  const CreateTaskRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateTaskPage();
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

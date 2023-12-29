import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../pages/create_task/create_task_page.dart';
import '../../pages/date_time_selection/date_picker_page.dart';
import '../../pages/date_time_selection/date_time_selection_page.dart';
import '../../pages/date_time_selection/time_picker_page.dart';
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

@TypedGoRoute<DateTimeSelectionRoute>(path: '/select-date-time')
@immutable
class DateTimeSelectionRoute extends GoRouteData {
  final DateTime initialDateTime;

  const DateTimeSelectionRoute(this.initialDateTime);

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      DateTimeSelectionPage(initialDateTime: initialDateTime);
}

@TypedGoRoute<TimePickerRoute>(path: '/time-picker')
@immutable
class TimePickerRoute extends GoRouteData {
  final DateTime initialTime;

  const TimePickerRoute(this.initialTime);

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TimePickerPage(initialTime: initialTime);
}

@TypedGoRoute<DatePickerRoute>(path: '/date-picker')
@immutable
class DatePickerRoute extends GoRouteData {
  final DateTime initialDate;

  const DatePickerRoute(this.initialDate);

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      DatePickerPage(initialDate: initialDate);
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

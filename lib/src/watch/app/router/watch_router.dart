import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/task_recurrence.dart';
import '../../pages/create_task/create_task_page.dart';
import '../../pages/date_time_selection/date_picker_page.dart';
import '../../pages/date_time_selection/date_time_selection_page.dart';
import '../../pages/date_time_selection/recurrence_selection_page.dart';
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
  final DateTime $extra;

  const DateTimeSelectionRoute(this.$extra);

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      DateTimeSelectionPage(initialDateTime: $extra);
}

@TypedGoRoute<TimePickerRoute>(path: '/time-picker')
@immutable
class TimePickerRoute extends GoRouteData {
  final DateTime $extra;

  const TimePickerRoute(this.$extra);

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TimePickerPage(initialTime: $extra);
}

@TypedGoRoute<DatePickerRoute>(path: '/date-picker')
@immutable
class DatePickerRoute extends GoRouteData {
  final DateTime $extra;

  const DatePickerRoute(this.$extra);

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      DatePickerPage(initialDate: $extra);
}

@TypedGoRoute<RecurrenceSelectionRoute>(path: '/recurrence-selection')
@immutable
class RecurrenceSelectionRoute extends GoRouteData {
  final TaskRecurrence? $extra;

  const RecurrenceSelectionRoute(this.$extra);

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      RecurrenceSelectionPage(
        initialRecurrence: $extra,
      );
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

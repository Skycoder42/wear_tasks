part of '../watch_router.dart';

@TypedGoRoute<DateTimeSelectionRoute>(path: '/select/task-due')
@immutable
class DateTimeSelectionRoute extends GoRouteData {
  final DateTime $extra;

  const DateTimeSelectionRoute(this.$extra);

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TaskDueSelectionPage(initialDateTime: $extra);
}

@TypedGoRoute<RecurrenceSelectionRoute>(path: '/select/recurrence')
@immutable
class RecurrenceSelectionRoute extends GoRouteData {
  final TaskRecurrence? $extra;

  const RecurrenceSelectionRoute(this.$extra);

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      RecurrencePickerPage(
        initialRecurrence: $extra,
      );
}

@TypedGoRoute<DateTimePickerRoute>(path: '/select/:mode')
@immutable
class DateTimePickerRoute extends GoRouteData {
  final DateTimePickerMode mode;
  final DateTime $extra;

  const DateTimePickerRoute(
    this.$extra, {
    this.mode = DateTimePickerMode.dateTime,
  });

  @override
  Widget build(BuildContext context, GoRouterState state) => DateTimePickerPage(
        initialDateTime: $extra,
        mode: mode,
      );
}

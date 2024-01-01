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

@TypedGoRoute<TimePickerRoute>(path: '/select/time')
@immutable
class TimePickerRoute extends GoRouteData {
  final DateTime $extra;

  const TimePickerRoute(this.$extra);

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TimePickerPage(initialTime: $extra);
}

@TypedGoRoute<DatePickerRoute>(path: '/select/date')
@immutable
class DatePickerRoute extends GoRouteData {
  final DateTime $extra;

  const DatePickerRoute(this.$extra);

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      DatePickerPage(initialDate: $extra);
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

part of '../watch_router.dart';

@TypedGoRoute<DateTimeSelectionRoute>(
  path: '/select/task-due',
  routes: [
    TypedGoRoute<TimePickerRoute>(path: 'time'),
    TypedGoRoute<DatePickerRoute>(path: 'date'),
    TypedGoRoute<RecurrenceSelectionRoute>(path: '/recurrence'),
  ],
)
@immutable
class DateTimeSelectionRoute extends GoRouteData {
  final DateTime $extra;

  const DateTimeSelectionRoute(this.$extra);

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TaskDueSelectionPage(initialDateTime: $extra);
}

@immutable
class TimePickerRoute extends GoRouteData {
  final DateTime $extra;

  const TimePickerRoute(this.$extra);

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TimePickerPage(initialTime: $extra);
}

@immutable
class DatePickerRoute extends GoRouteData {
  final DateTime $extra;

  const DatePickerRoute(this.$extra);

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      DatePickerPage(initialDate: $extra);
}

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

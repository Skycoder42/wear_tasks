import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_recurrence.freezed.dart';

enum RecurrenceFrequency {
  secondly,
  minutely,
  hourly,
  daily,
  weekly,
  monthly,
  yearly,
}

enum RecurrenceEndMode {
  infinite,
  count,
  endDate,
}

@freezed
class TaskRecurrence with _$TaskRecurrence {
  @Assert(
    'count == null || endDate == null',
    'Only one of count or endDate can be specified',
  )
  const factory TaskRecurrence({
    required RecurrenceFrequency frequency,
    @Default(1) int interval,
    int? count,
    DateTime? endDate,
  }) = _TaskRepetition;

  const TaskRecurrence._();

  RecurrenceEndMode get endMode => switch ((count, endDate)) {
        (null, null) => RecurrenceEndMode.infinite,
        (_, null) => RecurrenceEndMode.count,
        (null, _) => RecurrenceEndMode.endDate,
        _ => throw StateError('Both count and endDate are set!'),
      };
}

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

@freezed
class TaskRecurrence with _$TaskRecurrence {
  const factory TaskRecurrence({
    required RecurrenceFrequency frequency,
    @Default(1) int interval,
    int? count,
    DateTime? endDate,
  }) = _TaskRepetition;
}

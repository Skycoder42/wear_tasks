import 'package:freezed_annotation/freezed_annotation.dart';

import 'task_recurrence.dart';

part 'task.freezed.dart';

enum TaskStatus {
  needsAction('NEEDS-ACTION'),
  completed('COMPLETED');

  final String value;

  const TaskStatus(this.value);
}

enum TaskPriority {
  none(null),
  low(9),
  medium(5),
  high(1);

  final int? value;

  const TaskPriority(this.value);
}

@freezed
sealed class Task with _$Task {
  const factory Task({
    required String collectionUid,
    required String taskUid,
    required DateTime createdAt,
    required String summary,
    DateTime? dueDate,
    TaskRecurrence? recurrence,
    @Default(TaskStatus.needsAction) TaskStatus status,
    @Default(TaskPriority.none) TaskPriority priority,
    String? description,
  }) = _Task;
}

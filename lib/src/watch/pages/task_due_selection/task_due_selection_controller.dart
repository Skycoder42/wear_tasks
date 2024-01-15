import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../expressions/expression.dart';
import '../../repositories/expression_repository.dart';
import '../../repositories/settings.dart';

part 'task_due_selection_controller.freezed.dart';
part 'task_due_selection_controller.g.dart';

@freezed
class TaskDueSelectionState with _$TaskDueSelectionState {
  const factory TaskDueSelectionState({
    required List<Expression> expressions,
    required TimeOfDay defaultTime,
  }) = _TaskDueSelectionState;
}

@riverpod
class TaskDueSelectionController extends _$TaskDueSelectionController {
  @override
  Future<TaskDueSelectionState> build() async {
    final settings = await ref.watch(settingsProvider.future);
    final repo = ref.watch(expressionRepositoryProvider);

    return TaskDueSelectionState(
      expressions: await repo.loadExpressions().toList(),
      defaultTime: settings.tasks.defaultTime,
    );
  }
}

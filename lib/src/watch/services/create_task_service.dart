import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../background/tasks/task_manager.dart';
import '../../common/providers/sentry_provider_observer.dart';
import '../models/task.dart';
import '../repositories/item_repository.dart';
import 'task_factory.dart';

part 'create_task_service.freezed.dart';
part 'create_task_service.g.dart';

@freezed
class CreateTaskState with _$CreateTaskState {
  const factory CreateTaskState.ready() = CreateTaskReadyState;
  const factory CreateTaskState.saving() = CreateTaskSavingState;
  const factory CreateTaskState.saved(bool didUpload) = CreateTaskSavedState;
  @Implements<ErrorState>()
  const factory CreateTaskState.failed(Object error, StackTrace stackTrace) =
      CreateTaskFailedState;

  const CreateTaskState._();

  bool get isSaving => switch (this) {
        CreateTaskSavingState() => true,
        _ => false,
      };
}

@riverpod
class CreateTaskService extends _$CreateTaskService {
  final _logger = Logger('CreateTaskService');

  @override
  CreateTaskState build() => const CreateTaskState.ready();

  Future<void> createTask(Task task) async {
    state = const CreateTaskState.saving();
    try {
      final taskFactory = await ref.read(taskFactoryProvider.future);
      final repository =
          await ref.read(itemRepositoryProvider(task.collectionUid).future);

      final calendar = taskFactory.createTask(task);
      final didUpload = await repository.create(
        EtebaseItemMetadata(
          name: task.taskUid,
          mtime: task.createdAt,
        ),
        calendar,
      );

      if (!didUpload) {
        final taskManager = await ref.watch(taskManagerProvider.future);
        await taskManager.registerSyncTask();
      }

      state = CreateTaskState.saved(didUpload);

      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      _logger.severe('Failed to create task', e, s);
      state = CreateTaskState.failed(e, s);
    }
  }
}

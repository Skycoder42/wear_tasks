import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workmanager/workmanager.dart';

import '../workmanager.dart';
import 'sync_task.dart';

part 'task_manager.g.dart';

@Riverpod(keepAlive: true)
Future<TaskManager> taskManager(TaskManagerRef ref) async => TaskManager(
      ref,
      await ref.watch(workmanagerProvider.future),
    );

class TaskManager {
  static const _syncUniqueName = 'sync-task';

  static const _registry = {
    SyncTask.taskName: SyncTask(),
  };

  final TaskManagerRef _ref;
  final Workmanager _workmanager;

  TaskManager(this._ref, this._workmanager);

  Future<void> registerSyncTask() async {
    await _workmanager.registerOneOffTask(
      _syncUniqueName,
      SyncTask.taskName,
      initialDelay: const Duration(seconds: 10),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(seconds: 30),
      existingWorkPolicy: ExistingWorkPolicy.update,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  Future<void> clearSyncTask() =>
      _workmanager.cancelByUniqueName(_syncUniqueName);

  Future<bool> call(String taskName, Map<String, dynamic>? inputData) async {
    final task = _registry[taskName];
    if (task == null) {
      return true;
    }

    return await task(_ref, inputData);
  }
}

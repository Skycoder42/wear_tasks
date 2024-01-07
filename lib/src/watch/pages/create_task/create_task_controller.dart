import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/extensions/core_extensions.dart';
import '../../models/task.dart';
import '../../models/task_recurrence.dart';
import '../../repositories/settings.dart';
import 'collection_selection/active_collection.dart';
import 'collection_selection/collection_infos.dart';

part 'create_task_controller.freezed.dart';
part 'create_task_controller.g.dart';

@freezed
class CreateTaskState with _$CreateTaskState {
  const factory CreateTaskState({
    required DateTime initialDueDate,
    required List<CollectionInfo> collectionInfos,
    required String currentCollection,
    required DateTime currentDueDate,
    TaskRecurrence? currentRecurrence,
    @Default(TaskPriority.none) TaskPriority currentPriority,
  }) = _CreateTaskState;
}

@riverpod
class CreateTaskController extends _$CreateTaskController {
  @override
  Future<CreateTaskState> build() async {
    final collectionInfos = await ref.watch(collectionInfosProvider.future);
    final activeCollection = await ref.watch(activeCollectionProvider.future);
    final settings = await ref.watch(settingsProvider.future);

    final now = DateTime.now();
    final defaultTime = settings.defaultTime;
    final initialDueDate = defaultTime.toDateTime(
      DateTime(now.year, now.month, now.day + 1),
    );

    return CreateTaskState(
      initialDueDate: initialDueDate,
      collectionInfos: collectionInfos,
      currentCollection: activeCollection,
      currentDueDate: initialDueDate,
    );
  }

  Future<void> updateDueDate(DateTime dateTime, TaskRecurrence? recurrence) =>
      update(
        (state) => state.copyWith(
          currentDueDate: dateTime,
          currentRecurrence: recurrence,
        ),
      );

  Future<void> updatePriority(TaskPriority priority) => update(
        (state) => state.copyWith(
          currentPriority: priority,
        ),
      );

  Future<void> updateCollection(String uid) =>
      ref.read(activeCollectionProvider.notifier).setActive(uid);
}

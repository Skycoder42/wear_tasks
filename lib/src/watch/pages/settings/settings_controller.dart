import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/extensions/core_extensions.dart';
import '../../models/task.dart';
import '../../repositories/settings.dart';
import '../create_task/collection_selection/collection_infos.dart';

part 'settings_controller.freezed.dart';
part 'settings_controller.g.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    required List<CollectionInfo> collectionInfos,
    required String defaultCollection,
    required TimeOfDay defaultTime,
    required TaskPriority defaultPriority,
  }) = _SettingsState;

  const SettingsState._();

  CollectionInfo get defaultCollectionInfo =>
      collectionInfos.singleWhereOrNull((e) => e.uid == defaultCollection) ??
      collectionInfos.first;
}

@riverpod
class SettingsController extends _$SettingsController {
  @override
  Future<SettingsState> build() async {
    final collectionInfos = await ref.watch(collectionInfosProvider.future);
    final settings = await ref.watch(settingsProvider.future);

    return SettingsState(
      collectionInfos: collectionInfos,
      defaultCollection: collectionInfos
          .whereOrFirst((i) => i.uid == settings.tasks.defaultCollection)
          .uid,
      defaultTime: settings.tasks.defaultTime,
      defaultPriority: settings.tasks.defaultPriority,
    );
  }

  Future<void> updateDefaultCollection(String uid) => update((state) async {
        final settings = await ref.watch(settingsProvider.future);
        await settings.tasks.setDefaultCollection(uid);
        return state.copyWith(defaultCollection: uid);
      });

  Future<void> updateDefaultTime(TimeOfDay timeOfDay) => update((state) async {
        final settings = await ref.watch(settingsProvider.future);
        await settings.tasks.setDefaultTime(timeOfDay);
        return state.copyWith(defaultTime: timeOfDay);
      });

  Future<void> updateDefaultPriority(TaskPriority priority) =>
      update((state) async {
        final settings = await ref.watch(settingsProvider.future);
        await settings.tasks.setDefaultPriority(priority);
        return state.copyWith(defaultPriority: priority);
      });
}

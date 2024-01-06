import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../repositories/settings.dart';
import '../create_task/collection_selection/active_collection.dart';
import '../create_task/collection_selection/collection_infos.dart';

part 'settings_controller.freezed.dart';
part 'settings_controller.g.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    required List<CollectionInfo> collectionInfos,
    required String activeCollectionUid,
    required TimeOfDay defaultTime,
  }) = _SettingsState;

  const SettingsState._();

  CollectionInfo get activeCollectionInfo =>
      collectionInfos.singleWhereOrNull((e) => e.uid == activeCollectionUid) ??
      collectionInfos.first;
}

@riverpod
class SettingsController extends _$SettingsController {
  @override
  Future<SettingsState> build() async {
    final collectionInfos = await ref.watch(collectionInfosProvider.future);
    final activeCollection = await ref.watch(activeCollectionProvider.future);
    final settings = await ref.watch(settingsProvider.future);

    return SettingsState(
      collectionInfos: collectionInfos,
      activeCollectionUid: activeCollection,
      defaultTime: settings.defaultTime,
    );
  }

  Future<void> updateDefaultTime(TimeOfDay defaultTime) =>
      update((state) async {
        final settings = await ref.watch(settingsProvider.future);
        await settings.setDefaultTime(defaultTime);
        return state.copyWith(defaultTime: defaultTime);
      });

  Future<void> updateDefaultCollection(String uid) => update((state) async {
        final activeCollection = ref.watch(activeCollectionProvider.notifier);
        final settings = await ref.watch(settingsProvider.future);
        await settings.etebase.setDefaultCollection(uid);
        await activeCollection.setActive(uid);

        return state.copyWith(activeCollectionUid: uid);
      });
}

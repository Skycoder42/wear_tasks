import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/settings_service.dart';
import 'collection_infos.dart';

part 'active_collection.g.dart';

@riverpod
class ActiveCollection extends _$ActiveCollection {
  @override
  Future<String> build() async {
    final settings = await ref.watch(settingsServiceProvider.future);
    final collections = await ref.watch(collectionInfosProvider.future);

    final defaultCollection = await settings.getEtebaseDefaultCollection();
    if (defaultCollection != null &&
        collections.any((i) => i.uid == defaultCollection)) {
      return defaultCollection;
    } else {
      return collections.first.uid;
    }
  }

  Future<void> setActive(String newUid, {bool asDefault = false}) =>
      update((currentUid) async {
        if (newUid == currentUid) {
          return currentUid;
        }

        if (asDefault) {
          final settings = await ref.read(settingsServiceProvider.future);
          await settings.setEtebaseDefaultCollection(currentUid);
        }

        return newUid;
      });
}

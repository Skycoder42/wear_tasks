import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../repositories/settings.dart';
import 'collection_infos.dart';

part 'active_collection.g.dart';

@riverpod
class ActiveCollection extends _$ActiveCollection {
  @override
  Future<String> build() async {
    final settings = await ref.watch(settingsProvider.future);
    final collections = await ref.watch(collectionInfosProvider.future);

    final defaultCollection = settings.etebase.defaultCollection;
    if (defaultCollection != null &&
        collections.any((i) => i.uid == defaultCollection)) {
      return defaultCollection;
    } else {
      final collectionUid = collections.first.uid;
      await settings.etebase.setDefaultCollection(collectionUid);
      return collectionUid;
    }
  }

  Future<void> setActive(String newUid, {bool asDefault = false}) =>
      update((currentUid) async {
        if (newUid == currentUid) {
          return currentUid;
        }

        if (asDefault) {
          final settings = await ref.read(settingsProvider.future);
          await settings.etebase.setDefaultCollection(currentUid);
        }

        return newUid;
      });
}

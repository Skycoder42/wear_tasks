import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/providers/app_database_provider.dart';
import 'collection_storage.dart';
import 'drift/database.dart';

part 'item_storage.g.dart';

@Riverpod(keepAlive: true)
Future<ItemStorage> itemStorage(
  ItemStorageRef ref,
  String collectionUid,
) async {
  final colStorage = await ref.watch(collectionStorageProvider.future);
  final storage = ItemStorage(
    collectionUid,
    (await colStorage.getItemManager(collectionUid))!,
    await ref.watch(appDatabaseProvider.future),
  );
  ref.onDispose(storage.dispose);
  return storage;
}

class ItemStorage {
  final EtebaseItemManager _itemManager;
  final AppDatabase _database;

  final String collectionId;

  ItemStorage(this.collectionId, this._itemManager, this._database);

  Future<bool> get hasItems => _database.hasItems().getSingle();

  Stream<EtebaseItem> loadAll() async* {
    final items = await _database.listItems().get();
    for (final item in items) {
      yield await _itemManager.cacheLoad(item.data);
    }
  }

  Future<String> save(EtebaseItem item) async {
    final uid = await item.getUid();
    await _database.saveItem(
      StoredItem(
        id: uid,
        data: await _itemManager.cacheSaveWithContent(item),
        collectionId: collectionId,
      ),
    );
    return uid;
  }

  Future<void> remove(String uid) => _database.deleteItem(uid);

  Future<void> dispose() async {
    await _itemManager.dispose();
  }
}

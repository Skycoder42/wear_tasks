import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/providers/hive_provider.dart';
import 'collection_storage.dart';
import 'hive/hive_extensions.dart';
import 'hive/stored_item.dart';

part 'item_storage.g.dart';

@Riverpod(keepAlive: true)
Future<ItemStorage> itemStorage(
  ItemStorageRef ref,
  String collectionUid,
) async {
  await ref.watch(registerAdaptersProvider.future);
  final colStorage = await ref.watch(collectionStorageProvider.future);
  final boxFactory = await ref.watch(hiveBoxFactoryProvider.future);
  final storage = ItemStorage(
    (await colStorage.getItemManager(collectionUid))!,
    await boxFactory(collectionUid),
  );
  ref.onDispose(storage.dispose);
  return storage;
}

class ItemStorage {
  final EtebaseItemManager _itemManager;
  final LazyBox<StoredItem> _cacheBox;
  final _logger = Logger('$ItemStorage');

  ItemStorage(this._itemManager, this._cacheBox);

  bool get hasItems => _cacheBox.isNotEmpty;

  Stream<EtebaseItem> loadAll() async* {
    _logger.finest('List all items from storage');

    for (final uid in _cacheBox.keys.cast<String>()) {
      _logger.finest('Attempting to load item $uid from storage');
      final item = await _cacheBox.get(uid);
      if (item != null) {
        _logger.finest('Found item $uid');
        yield await _itemManager.cacheLoad(item.data);
      } else {
        _logger.fine('No item with uid $uid in storage');
      }
    }
  }

  Future<String> save(EtebaseItem item) async {
    final uid = await item.getUid();
    _logger.finest('Saving item $uid to storage');

    await _cacheBox.put(
      uid,
      StoredItem(await _itemManager.cacheSaveWithContent(item)),
    );
    _logger.finer('Saved item $uid to storage');
    return uid;
  }

  Future<void> remove(String uid) async {
    _logger.finer('Removing item $uid from storage');
    await _cacheBox.delete(uid);
  }

  Future<void> clear({bool fromDisk = false}) async {
    if (fromDisk) {
      _logger.fine('Deleting item storage from disk');
      await _cacheBox.deleteFromDisk();
    } else {
      _logger.fine('Clearing item storage');
      await _cacheBox.clear();
    }
  }

  Future<void> dispose() => Future.wait([
        _cacheBox.close(),
        _itemManager.dispose(),
      ]);
}

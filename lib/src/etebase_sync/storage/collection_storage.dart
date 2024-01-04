import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:hive/hive.dart';

import '../hive/model/stored_collection.dart';

class CollectionStorage {
  final EtebaseCollectionManager collectionManager;
  final LazyBox<StoredCollection> cacheBox;

  CollectionStorage({
    required this.collectionManager,
    required this.cacheBox,
  });

  Stream<EtebaseCollection> loadAll() => _loadAll();

  Stream<EtebaseCollection> loadPendingUploads() =>
      _loadAll(pendingUpdateOnly: true);

  Future<EtebaseCollection?> load(String uid) => _load(uid);

  Future<void> save(
    EtebaseCollection collection, {
    String? uidHint,
    bool pendingUpload = false,
  }) async {
    final uid = uidHint ?? await collection.getUid();
    final collectionData =
        await collectionManager.cacheSaveWithContent(collection);
    await cacheBox.put(
      uid,
      StoredCollection(
        collectionData,
        pendingUpload: pendingUpload,
      ),
    );
  }

  Future<void> remove(String uid) async {
    await cacheBox.delete(uid);
  }

  Future<void> clear({bool fromDisk = false}) async {
    if (fromDisk) {
      await cacheBox.deleteFromDisk();
    } else {
      await cacheBox.clear();
    }
  }

  Future<void> dispose() async {
    await cacheBox.close();
    await collectionManager.dispose();
  }

  Future<EtebaseCollection?> _load(
    String uid, {
    bool pendingUpdateOnly = false,
  }) async {
    final collection = await cacheBox.get(uid);
    if (collection == null ||
        (pendingUpdateOnly && !collection.pendingUpload)) {
      return null;
    }

    return collectionManager.cacheLoad(collection.data);
  }

  Stream<EtebaseCollection> _loadAll({
    bool pendingUpdateOnly = false,
  }) async* {
    for (final uid in cacheBox.keys.cast<String>()) {
      final collection = await _load(uid, pendingUpdateOnly: pendingUpdateOnly);
      if (collection != null) {
        yield collection;
      }
    }
  }
}

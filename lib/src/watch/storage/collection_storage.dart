import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/providers/app_database_provider.dart';
import '../../watch/services/account_service.dart';
import 'drift/database.dart';

part 'collection_storage.g.dart';

@Riverpod(keepAlive: true)
Future<CollectionStorage> collectionStorage(CollectionStorageRef ref) async {
  final account = await ref.watch(etebaseAccountProvider.future);
  final storage = CollectionStorage(
    await account.getCollectionManager(),
    await ref.watch(appDatabaseProvider.future),
  );
  ref.onDispose(storage.dispose);
  return storage;
}

class CollectionStorage {
  final EtebaseCollectionManager _collectionManager;
  final AppDatabase _database;

  CollectionStorage(this._collectionManager, this._database);

  Stream<EtebaseCollection> loadAll() async* {
    final collections = await _database.listCollections().get();
    for (final collection in collections) {
      yield await _collectionManager.cacheLoad(collection.data);
    }
  }

  Future<EtebaseCollection?> load(String uid) async {
    final collection = await _database.getCollection(uid).getSingleOrNull();
    return collection != null
        ? _collectionManager.cacheLoad(collection.data)
        : null;
  }

  Future<bool> hasPendingUploads() => _database.hasPendingUploads().getSingle();

  Stream<EtebaseCollection> loadPendingUploads() async* {
    final collections = await _database.listPendingCollections().get();
    for (final collection in collections) {
      yield await _collectionManager.cacheLoad(collection.data);
    }
  }

  Future<void> save(
    String uid,
    EtebaseCollection collection, {
    bool pendingUpload = false,
  }) async {
    await _database.saveCollection(
      StoredCollection(
        id: uid,
        data: await _collectionManager.cacheSaveWithContent(collection),
        pendingUpload: pendingUpload,
      ),
    );
  }

  Future<void> remove(String uid) async {
    await _database.deleteCollection(uid);
  }

  Future<EtebaseItemManager?> getItemManager(String uid) async {
    final collection = await load(uid);
    try {
      if (collection != null) {
        return _collectionManager.getItemManager(collection);
      } else {
        return null;
      }
    } finally {
      await collection?.dispose();
    }
  }

  Future<void> dispose() async {
    await _collectionManager.dispose();
  }
}

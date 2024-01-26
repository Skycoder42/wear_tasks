import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../watch/services/account_service.dart';
import 'drift/database.dart';

part 'collection_storage.g.dart';

@Riverpod(keepAlive: true)
Future<CollectionStorage> collectionStorage(CollectionStorageRef ref) async {
  await ref.watch(registerAdaptersProvider.future);
  final account = await ref.watch(etebaseAccountProvider.future);
  final boxFactory = await ref.watch(hiveBoxFactoryProvider.future);
  final storage = CollectionStorage(
    await account.getCollectionManager(),
    await boxFactory('collections'),
  );
  ref.onDispose(storage.dispose);
  return storage;
}

class CollectionStorage {
  final EtebaseCollectionManager _collectionManager;
  final AppDatabase _database;
  final _logger = Logger('$CollectionStorage');

  CollectionStorage(this._collectionManager, this._database);

  Stream<EtebaseCollection> loadAll() async* {
    final collections =
        await _database.select(_database.storedCollections).get();
    for (final collection in collections) {
      yield await _collectionManager.cacheLoad(collection.data);
    }
  }

  Future<EtebaseCollection?> load(String uid) async {
    final collection = await (_database.select(_database.storedCollections)
          ..where((tbl) => tbl.id.equals(uid)))
        .getSingleOrNull();

    return collection != null
        ? _collectionManager.cacheLoad(collection.data)
        : null;
  }

  Future<bool> hasPendingUploads() async {
    for (final uid in _cacheBox.keys.cast<String>()) {
      final item = await _cacheBox.get(uid);
      if (item case StoredCollection(pendingUpload: true)) {
        return true;
      }
    }

    return false;
  }

  Stream<EtebaseCollection> loadPendingUploads() =>
      _loadAll(pendingUpdateOnly: true);

  Future<void> save(
    String uid,
    EtebaseCollection collection, {
    bool pendingUpload = false,
  }) async {
    _logger.finest(
      'Saving collection $uid to storage (pendingUpload: $pendingUpload)',
    );

    await _cacheBox.put(
      uid,
      StoredCollection(
        await _collectionManager.cacheSaveWithContent(collection),
        pendingUpload: pendingUpload,
      ),
    );
    _logger.finer('Saved collection $uid to storage');
  }

  Future<void> remove(String uid) async {
    _logger.finer('Removing collection $uid from storage');
    await _cacheBox.delete(uid);
  }

  Future<void> clear({bool fromDisk = false}) async {
    if (fromDisk) {
      _logger.fine('Deleting collection storage from disk');
      await _cacheBox.deleteFromDisk();
    } else {
      _logger.fine('Clearing collection storage');
      await _cacheBox.clear();
    }
  }

  Future<EtebaseItemManager?> getItemManager(String uid) async {
    final collection = await _load(uid);
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

  Future<void> dispose() => Future.wait([
        _cacheBox.close(),
        _collectionManager.dispose(),
      ]);

  Future<EtebaseCollection?> _load(
    String uid, {
    bool pendingUpdateOnly = false,
  }) async {
    _logger.finest(
      'Attempting to load collection $uid from storage '
      '(pendingUpdateOnly: $pendingUpdateOnly)',
    );
    final collection = await _cacheBox.get(uid);

    if (collection == null) {
      _logger.fine('No collection with uid $uid in storage');
      return null;
    } else if (pendingUpdateOnly && !collection.pendingUpload) {
      _logger.finer('Skipping collection $uid as it is not pending');
      return null;
    }

    _logger.finest('Found collection $uid');
    return _collectionManager.cacheLoad(collection.data);
  }
}

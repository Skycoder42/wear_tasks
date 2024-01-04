import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:hive/hive.dart';
import 'package:logging/logging.dart';

import '../hive/model/stored_collection.dart';

class CollectionStorage {
  final EtebaseCollectionManager collectionManager;
  final LazyBox<StoredCollection> cacheBox;
  final _logger = Logger('CollectionStorage');

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
    _logger.finest(
      'Saving collection $uid to storage (pendingUpload: $pendingUpload)',
    );

    await cacheBox.put(
      uid,
      StoredCollection(
        await collectionManager.cacheSaveWithContent(collection),
        pendingUpload: pendingUpload,
      ),
    );
    _logger.finer('Saved collection $uid to storage');
  }

  Future<void> remove(String uid) async {
    _logger.finer('Removing collection $uid from storage');
    await cacheBox.delete(uid);
  }

  Future<void> clear({bool fromDisk = false}) async {
    if (fromDisk) {
      _logger.fine('Deleting collection storage from disk');
      await cacheBox.deleteFromDisk();
    } else {
      _logger.fine('Clearing collection storage');
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
    _logger.finest(
      'Attempting to load collection $uid from storage '
      '(pendingUpdateOnly: $pendingUpdateOnly)',
    );
    final collection = await cacheBox.get(uid);

    if (collection == null) {
      _logger.fine('No collection with uid $uid in storage');
      return null;
    } else if (pendingUpdateOnly && !collection.pendingUpload) {
      _logger.finer('Skipping collection $uid as it is not pending');
      return null;
    }

    _logger.finest('Found collection $uid');
    return collectionManager.cacheLoad(collection.data);
  }

  Stream<EtebaseCollection> _loadAll({
    bool pendingUpdateOnly = false,
  }) async* {
    _logger.finest(
      'List all collections '
      '${pendingUpdateOnly ? 'with pending uploads ' : ''}'
      'from storage',
    );

    for (final uid in cacheBox.keys.cast<String>()) {
      final collection = await _load(uid, pendingUpdateOnly: pendingUpdateOnly);
      if (collection != null) {
        yield collection;
      }
    }
  }
}

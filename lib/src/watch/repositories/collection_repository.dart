import 'dart:async';
import 'dart:typed_data';

import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/account_service.dart';
import '../storage/collection_storage.dart';
import 'repository_mixin.dart';

part 'collection_repository.g.dart';

@Riverpod(keepAlive: true)
Future<CollectionRepository> collectionRepository(
  CollectionRepositoryRef ref,
) async {
  final account = await ref.watch(etebaseAccountProvider.future);
  final repository = CollectionRepository(
    await account.getCollectionManager(),
    await ref.watch(collectionStorageProvider.future),
  );
  ref.onDispose(repository.dispose);
  return repository;
}

class CollectionRepository with RepositoryMixin {
  static const _tasksCollectionType = 'etebase.vtodo';

  final EtebaseCollectionManager _collectionManager;
  final CollectionStorage _collectionStorage;

  @override
  @visibleForOverriding
  final logger = Logger('CollectionRepository');

  final _collections = <String, EtebaseCollection>{};
  final _responseRefs = <EtebaseCollectionListResponse>[];
  String? _stoken;

  CollectionRepository(this._collectionManager, this._collectionStorage);

  Stream<String> listAll({bool clearCache = false}) async* {
    if (clearCache) {
      await _clearCache();
    }

    yield* Stream.fromIterable(_collections.keys);

    try {
      var isDone = false;
      do {
        final response = await _collectionManager.list(
          _tasksCollectionType,
          EtebaseFetchOptions(stoken: _stoken),
        );
        _responseRefs.add(response);

        for (final item in await response.getData()) {
          final uid = await item.getUid();
          final deleted = await item.isDeleted();
          if (deleted) {
            await _removeCache(uid);
          } else if (await _updateCache(uid, item)) {
            yield uid;
          }
        }

        for (final item in await response.getRemovedMemberships()) {
          final uid = await item.getUid();
          await _removeCache(uid);
        }

        _stoken = await response.getStoken();
        isDone = await response.isDone();
      } while (!isDone);

      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      if (!handleNetworkError(e, s)) {
        rethrow;
      }

      await for (final collection in _collectionStorage.loadAll()) {
        final uid = await collection.getUid();
        if (await _updateCache(uid, collection, fromStorage: true)) {
          yield uid;
        }
      }
    }
  }

  Future<EtebaseItemMetadata?> getMeta(String uid) async {
    final collection = await _getCol(uid);
    return collection?.getMeta();
  }

  Future<EtebaseItemManager?> getItemManager(String uid) async {
    final collection = await _getCol(uid);
    if (collection != null) {
      return _collectionManager.getItemManager(collection);
    } else {
      return null;
    }
  }

  Future<({String uid, bool didUpload})> create(
    EtebaseItemMetadata metadata,
  ) async {
    final collection = await _collectionManager.create(
      _tasksCollectionType,
      metadata,
      Uint8List(0),
    );

    final uid = await collection.getUid();
    var didUpload = false;
    await _updateCache(uid, collection, needsUpload: true);
    try {
      await _collectionManager.upload(collection);
      didUpload = true;
      await _collectionStorage.save(uid, collection);

      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      await collection.dispose();
      if (!handleNetworkError(e, s, 'col: $uid')) {
        rethrow;
      }
    }

    return (uid: uid, didUpload: didUpload);
  }

  Future<bool> hasPendingUploads() => _collectionStorage.hasPendingUploads();

  Future<void> retryPendingUploads() async {
    await for (final collection in _collectionStorage.loadPendingUploads()) {
      final uid = await collection.getUid();
      try {
        await _collectionManager.upload(collection);
        await _updateCache(uid, collection);

        // ignore: avoid_catches_without_on_clauses
      } catch (e, s) {
        if (!handleNetworkError(e, s, 'col: $uid')) {
          logger.severe('Failed to upload collection $uid', e, s);
          await _updateCache(uid, collection); // ignore error
          rethrow;
        }
      } finally {
        await collection.dispose();
      }
    }
  }

  Future<void> dispose() async {
    await _clearCache();
    await _collectionManager.dispose();
  }

  Future<EtebaseCollection?> _getCol(String uid) async {
    if (_collections[uid] case final EtebaseCollection collection) {
      return collection;
    }

    final collection = await _collectionManager.fetch(uid);
    if (await collection.isDeleted()) {
      await _removeCache(uid);
      return null;
    } else {
      await _updateCache(uid, collection);
      return collection;
    }
  }

  Future<bool> _updateCache(
    String uid,
    EtebaseCollection collection, {
    bool needsUpload = false,
    bool fromStorage = false,
  }) async {
    var didCreate = false;
    _collections.update(
      uid,
      (oldValue) {
        if (fromStorage) {
          unawaited(collection.dispose());
          return oldValue;
        } else {
          unawaited(oldValue.dispose());
          return collection;
        }
      },
      ifAbsent: () {
        didCreate = true;
        return collection;
      },
    );
    if (!fromStorage) {
      await _collectionStorage.save(
        uid,
        collection,
        pendingUpload: needsUpload,
      );
    }
    return didCreate;
  }

  Future<void> _removeCache(String uid) async {
    await _collectionStorage.remove(uid);
    await _collections.remove(uid)?.dispose();
  }

  Future<void> _clearCache() async {
    try {
      await Future.wait(
        _collections.values
            .map((r) => r.dispose())
            .followedBy(_responseRefs.map((r) => r.dispose())),
      );
    } finally {
      _collections.clear();
      _responseRefs.clear();
      _stoken = null;
    }
  }
}

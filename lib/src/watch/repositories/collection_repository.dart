import 'dart:async';
import 'dart:typed_data';

import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/account_service.dart';

part 'collection_repository.g.dart';

// coverage:ignore-start
@Riverpod(keepAlive: true)
Future<CollectionRepository> collectionRepository(
  CollectionRepositoryRef ref,
) async {
  final account = await ref.watch(etebaseAccountProvider.future);
  final repository = CollectionRepository(
    await account.getCollectionManager(),
  );
  ref.onDispose(repository.dispose);
  return repository;
}
// coverage:ignore-end

class CollectionRepository {
  static const _tasksCollectionType = 'etebase.vtodo';

  final EtebaseCollectionManager _collectionManager;

  final _collections = <String, EtebaseCollection>{};
  final _responseRefs = <EtebaseCollectionListResponse>[];
  String? _stoken;

  CollectionRepository(this._collectionManager);

  Stream<String> listAll({bool clearCache = false}) async* {
    if (clearCache) {
      await _clearCache();
    }

    yield* Stream.fromIterable(_collections.keys);

    var isDone = false;
    do {
      final response = await _collectionManager.list(
        _tasksCollectionType,
        EtebaseFetchOptions(stoken: _stoken),
      );
      _responseRefs.add(response);

      for (final item in await response.getData()) {
        final uid = await item.getUid();
        if (_updateCache(uid, item)) {
          yield uid;
        }
      }

      _stoken = await response.getStoken();
      isDone = await response.isDone();
    } while (!isDone);
  }

  Future<EtebaseItemMetadata> getMeta(String uid) async {
    final collection = await _getCol(uid);
    return collection.getMeta();
  }

  Future<EtebaseItemManager> getItemManager(String uid) async {
    final collection = await _getCol(uid);
    return _collectionManager.getItemManager(collection);
  }

  Future<String> create(EtebaseItemMetadata metadata) async {
    final collection = await _collectionManager.create(
      _tasksCollectionType,
      metadata,
      Uint8List(0),
    );

    try {
      final uid = await collection.getUid();
      await _collectionManager.upload(collection);
      _updateCache(uid, collection);
      return uid;

      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      await collection.dispose();
      rethrow;
    }
  }

  Future<void> dispose() async {
    await _clearCache();
    await _collectionManager.dispose();
  }

  Future<EtebaseCollection> _getCol(String uid) async {
    if (_collections[uid] case final EtebaseCollection collection) {
      return collection;
    }

    final collection = await _collectionManager.fetch(uid);
    _updateCache(uid, collection);
    return collection;
  }

  bool _updateCache(String uid, EtebaseCollection collection) {
    var didCreate = false;
    _collections.update(
      uid,
      (oldValue) {
        unawaited(oldValue.dispose());
        return collection;
      },
      ifAbsent: () {
        didCreate = true;
        return collection;
      },
    );
    return didCreate;
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

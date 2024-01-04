import 'dart:typed_data';

import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/hive_provider.dart';
import '../../services/account_service.dart';

part 'collection_storage.freezed.dart';
part 'collection_storage.g.dart';

@Riverpod(keepAlive: true)
Future<void> storedCollectionRegistration(
  StoredCollectionRegistrationRef ref,
) async {
  final hive = await ref.watch(hiveProvider.future);
  hive.registerAdapter(StoredCollectionAdapter());
}

@Riverpod(keepAlive: true)
Future<CollectionStorage> collectionStorage(CollectionStorageRef ref) async {
  await ref.watch(storedCollectionRegistrationProvider.future);

  final account = await ref.watch(etebaseAccountProvider.future);
  final boxFactory = await ref.watch(hiveBoxFactoryProvider.future);
  final cache = CollectionStorage(
    await account.getCollectionManager(),
    await boxFactory(CollectionStorage._boxKey),
  );
  ref.onDispose(cache.dispose);
  return cache;
}

@freezed
class StoredCollection with _$StoredCollection {
  @HiveType(typeId: 1, adapterName: 'StoredCollectionAdapter')
  const factory StoredCollection(
    @HiveField(0) Uint8List data, {
    @HiveField(1) @Default(false) bool needsUpload,
  }) = _StoredCollection;
}

class CollectionStorage {
  static const _boxKey = 'collections';

  final EtebaseCollectionManager _collectionManager;
  final LazyBox<StoredCollection> _cacheBox;

  CollectionStorage(this._collectionManager, this._cacheBox);

  Stream<EtebaseCollection> loadAll({bool needsUploadOnly = false}) async* {
    for (final uid in _cacheBox.keys.cast<String>()) {
      final collection = await load(uid, needsUploadOnly: needsUploadOnly);
      if (collection != null) {
        yield collection;
      }
    }
  }

  Future<EtebaseCollection?> load(
    String uid, {
    bool needsUploadOnly = false,
  }) async {
    final collection = await _cacheBox.get(uid);
    if (collection == null || (needsUploadOnly && !collection.needsUpload)) {
      return null;
    }

    return _collectionManager.cacheLoad(collection.data);
  }

  Future<void> save(
    EtebaseCollection collection, {
    bool needsUpload = false,
  }) async {
    final uid = await collection.getUid();
    final collectionData =
        await _collectionManager.cacheSaveWithContent(collection);
    await _cacheBox.put(
      uid,
      StoredCollection(
        collectionData,
        needsUpload: needsUpload,
      ),
    );
  }

  Future<void> remove(String uid) async {
    await _cacheBox.delete(uid);
  }

  Future<void> dispose() async {
    await _collectionManager.dispose();
  }
}

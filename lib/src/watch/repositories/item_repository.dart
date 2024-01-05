import 'dart:convert';
import 'dart:typed_data';

import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../ical/ical_codec.dart';
import '../ical/ical_component.dart';
import '../storage/item_storage.dart';
import 'collection_repository.dart';
import 'repository_mixin.dart';

part 'item_repository.g.dart';

// coverage:ignore-start
@Riverpod(keepAlive: true)
Future<ItemRepository> itemRepository(
  ItemRepositoryRef ref,
  String collectionUid,
) async {
  final colRepo = await ref.watch(collectionRepositoryProvider.future);
  final repository = ItemRepository(
    collectionUid,
    (await colRepo.getItemManager(collectionUid))!,
    await ref.watch(itemStorageProvider(collectionUid).future),
    iCalBinaryCodec,
  );
  ref.onDispose(repository.dispose);
  return repository;
}
// coverage:ignore-end

class ItemRepository with RepositoryMixin {
  final String collectionUid;
  final EtebaseItemManager _itemManager;
  final ItemStorage _itemStorage;
  final Codec<ICalendar, Uint8List> _codec;

  @override
  @visibleForOverriding
  final logger = Logger('$ItemRepository');

  ItemRepository(
    this.collectionUid,
    this._itemManager,
    this._itemStorage,
    this._codec,
  );

  Future<bool> create(EtebaseItemMetadata metadata, ICalendar data) async {
    final item = await _itemManager.create(metadata, _codec.encode(data));
    final uid = await _itemStorage.save(item);
    try {
      await _itemManager.batch([item]);
      await _itemStorage.remove(uid);
      return true;

      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      if (handleNetworkError(e, s, 'item: $uid')) {
        return false;
      }
      rethrow;
    } finally {
      await item.dispose();
    }
  }

  bool hasPendingUploads() => _itemStorage.hasItems;

  Future<void> retryPendingUploads() async {
    await for (final item in _itemStorage.loadAll()) {
      final uid = await item.getUid();
      try {
        await _itemManager.batch([item]);
        await _itemStorage.remove(uid);

        // ignore: avoid_catches_without_on_clauses
      } catch (e, s) {
        if (!handleNetworkError(e, s, 'item: $uid')) {
          logger.severe('Failed to upload item $uid', e, s);
          await _itemStorage.remove(uid); // ignore error
          rethrow;
        }
      } finally {
        await item.dispose();
      }
    }
  }

  Future<void> dispose() async {
    await _itemManager.dispose();
  }
}

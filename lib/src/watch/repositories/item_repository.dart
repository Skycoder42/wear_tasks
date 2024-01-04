import 'dart:convert';
import 'dart:typed_data';

import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../ical/ical_codec.dart';
import '../ical/ical_component.dart';
import 'collection_repository.dart';

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
    iCalBinaryCodec,
  );
  ref.onDispose(repository.dispose);
  return repository;
}
// coverage:ignore-end

class ItemRepository {
  final String collectionUid;
  final EtebaseItemManager _itemManager;
  final Codec<ICalendar, Uint8List> _codec;

  ItemRepository(
    this.collectionUid,
    this._itemManager,
    this._codec,
  );

  Future<void> dispose() async {
    await _itemManager.dispose();
  }

  Future<void> create(EtebaseItemMetadata metadata, ICalendar data) async {
    final item = await _itemManager.create(metadata, _codec.encode(data));
    try {
      await _itemManager.batch([item]);
    } finally {
      await item.dispose();
    }
  }
}

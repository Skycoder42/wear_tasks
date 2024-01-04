import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'stored_item.freezed.dart';
part 'stored_item.g.dart';

@freezed
class StoredItem with _$StoredItem {
  @HiveType(typeId: 202, adapterName: '_StoredItemAdapter')
  const factory StoredItem(
    @HiveField(0) Uint8List data, {
    @HiveField(1) @Default(false) bool pendingUpload,
  }) = _StoredItem;
}

class StoredItemAdapter extends _StoredItemAdapter {
  final int? _typeId;

  StoredItemAdapter([this._typeId]);

  @override
  int get typeId => _typeId ?? super.typeId;
}

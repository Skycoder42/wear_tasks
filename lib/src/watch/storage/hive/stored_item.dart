import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'stored_item.freezed.dart';
part 'stored_item.g.dart';

@freezed
class StoredItem with _$StoredItem {
  @HiveType(typeId: 2, adapterName: 'StoredItemAdapter')
  const factory StoredItem(@HiveField(0) Uint8List data) = _StoredItem;
}

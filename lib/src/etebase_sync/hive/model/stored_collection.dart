import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'stored_collection.freezed.dart';
part 'stored_collection.g.dart';

@freezed
class StoredCollection with _$StoredCollection {
  @HiveType(typeId: 201, adapterName: '_StoredCollectionAdapter')
  const factory StoredCollection(
    @HiveField(0) Uint8List data, {
    @HiveField(1) @Default(false) bool pendingUpload,
  }) = _StoredCollection;
}

class StoredCollectionAdapter extends _StoredCollectionAdapter {
  final int? _typeId;

  StoredCollectionAdapter([this._typeId]);

  @override
  int get typeId => _typeId ?? super.typeId;
}

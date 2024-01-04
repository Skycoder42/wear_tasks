import 'package:hive/hive.dart';

import 'model/stored_collection.dart';
import 'model/stored_item.dart';

extension HiveInterfaceX on HiveInterface {
  void registerEtebaseAdapters({
    int? typeIdOffset,
    bool override = false,
  }) {
    registerAdapter<StoredCollection>(
      StoredCollectionAdapter(_maybeId(typeIdOffset, 1)),
      override: override,
    );
    registerAdapter<StoredItem>(
      StoredItemAdapter(_maybeId(typeIdOffset, 1)),
      override: override,
    );
  }

  static int? _maybeId(int? offset, int id) =>
      offset != null ? offset + id : null;
}

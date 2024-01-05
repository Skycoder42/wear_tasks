import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/hive_provider.dart';
import 'stored_collection.dart';
import 'stored_item.dart';

part 'hive_extensions.g.dart';

@Riverpod(keepAlive: true)
Future<void> registerAdapters(RegisterAdaptersRef ref) async {
  final hive = await ref.watch(hiveProvider.future);
  hive.registerEtebaseAdapters();
}

extension HiveInterfaceX on HiveInterface {
  void registerEtebaseAdapters() {
    registerAdapter<StoredCollection>(StoredCollectionAdapter());
    registerAdapter<StoredItem>(StoredItemAdapter());
  }
}

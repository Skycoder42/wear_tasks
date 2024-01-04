import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../etebase_sync/hive/hive_extensions.dart';
import '../../etebase_sync/storage/collection_storage.dart';
import '../../watch/services/account_service.dart';
import 'hive_provider.dart';

part 'etebase_sync_provider.g.dart';

@Riverpod(keepAlive: true)
Future<void> registerAdapters(RegisterAdaptersRef ref) async {
  final hive = await ref.watch(hiveProvider.future);
  hive.registerEtebaseAdapters();
}

@Riverpod(keepAlive: true)
Future<CollectionStorage> collectionStorage(CollectionStorageRef ref) async {
  await ref.watch(registerAdaptersProvider.future);
  final account = await ref.watch(etebaseAccountProvider.future);
  final boxFactory = await ref.watch(hiveBoxFactoryProvider.future);
  final storage = CollectionStorage(
    collectionManager: await account.getCollectionManager(),
    cacheBox: await boxFactory('collections'),
  );
  ref.onDispose(storage.dispose);
  return storage;
}

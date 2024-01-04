import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../watch/repositories/settings.dart';

part 'hive_provider.g.dart';

@Riverpod(keepAlive: true)
Future<HiveInterface> hive(HiveRef ref) async {
  await Hive.initFlutter();
  ref.onDispose(Hive.close);
  return Hive;
}

@Riverpod(keepAlive: true)
Future<HiveCipher> hiveCipher(HiveCipherRef ref) async {
  final settings = await ref.watch(settingsProvider.future);
  var key = settings.hive.cipherKey;
  if (key == null) {
    final hive = await ref.read(hiveProvider.future);
    key = hive.generateSecureKey();
    await settings.hive.setCipherKey(key);
  }
  return HiveAesCipher(key);
}

@Riverpod(keepAlive: true)
Future<HiveBoxFactory> hiveBoxFactory(HiveBoxFactoryRef ref) async =>
    HiveBoxFactory(
      await ref.watch(hiveProvider.future),
      await ref.watch(hiveCipherProvider.future),
    );

class HiveBoxFactory {
  final HiveInterface hive;
  final HiveCipher cipher;

  HiveBoxFactory(this.hive, this.cipher);

  Future<LazyBox<T>> call<T>(String boxName) => hive.openLazyBox<T>(
        boxName,
        encryptionCipher: cipher,
      );
}

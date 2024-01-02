import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../watch/services/settings_service.dart';

part 'hive_provider.g.dart';

@Riverpod(keepAlive: true)
Future<HiveInterface> hive(HiveRef ref) async {
  await Hive.initFlutter();
  ref.onDispose(Hive.close);
  return Hive;
}

@Riverpod(keepAlive: true)
Future<HiveCipher> hiveCipher(HiveCipherRef ref) async {
  final settings = await ref.watch(settingsServiceProvider.future);
  var key = await settings.getHiveCipherKey();
  if (key == null) {
    final hive = await ref.read(hiveProvider.future);
    key = hive.generateSecureKey();
    await settings.setHiveCipherKey(key);
  }
  return HiveAesCipher(key);
}

@Riverpod(keepAlive: true)
Future<LazyBox> hiveBox(HiveBoxRef ref, String boxName) async {
  final hive = await ref.watch(hiveProvider.future);
  final box = await hive.openLazyBox(
    boxName,
    encryptionCipher: await ref.watch(hiveCipherProvider.future),
  );
  ref.onDispose(box.close);
  return box;
}

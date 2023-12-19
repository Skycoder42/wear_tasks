import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package_info_provider.dart';

part 'secure_storage.g.dart';

@Riverpod(keepAlive: true)
Future<FlutterSecureStorage> secureStorage(SecureStorageRef ref) async {
  final packageInfo = await ref.watch(packageInfoProvider.future);
  return FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: packageInfo.packageName,
      preferencesKeyPrefix: packageInfo.packageName,
      resetOnError: true,
    ),
  );
}

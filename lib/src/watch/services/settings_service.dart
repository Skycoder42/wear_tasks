import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/providers/secure_storage.dart';

part 'settings_service.g.dart';

// coverage:ignore-start
@Riverpod(keepAlive: true)
Future<SettingsService> settingsService(SettingsServiceRef ref) async {
  final service = SettingsService(
    await ref.watch(secureStorageProvider.future),
  );
  if (!await service._secureStorage
      .containsKey(key: SettingsService._initKey)) {
    await service._secureStorage
        .write(key: SettingsService._initKey, value: '');
  }
  return service;
}
// coverage:ignore-end

class SettingsService {
  static const _initKey = '__init';
  static const _etebaseAccountDataKey = 'etebase.accountData';
  static const _etebaseServerUrlKey = 'etebase.serverUrl';

  final FlutterSecureStorage _secureStorage;

  SettingsService(this._secureStorage);

  Future<String?> getEtebaseAccountData() =>
      _secureStorage.read(key: _etebaseAccountDataKey);

  Future<void> setEtebaseAccountData(String accountData) =>
      _secureStorage.write(key: _etebaseAccountDataKey, value: accountData);

  Future<void> removeEtebaseAccountData() =>
      _secureStorage.delete(key: _etebaseAccountDataKey);

  Future<Uri?> getEtebaseServerUrl() async {
    final rawUri = await _secureStorage.read(key: _etebaseServerUrlKey);
    return rawUri != null ? Uri.parse(rawUri) : null;
  }

  Future<void> setEtebaseServerUrl(Uri serverUrl) => _secureStorage.write(
        key: _etebaseServerUrlKey,
        value: serverUrl.toString(),
      );

  Future<void> removeEtebaseServerUrl() =>
      _secureStorage.delete(key: _etebaseAccountDataKey);
}

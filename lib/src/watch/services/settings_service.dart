import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/providers/secure_storage.dart';

part 'settings_service.g.dart';

// coverage:ignore-start
@riverpod
Future<SettingsService> settingsService(SettingsServiceRef ref) async =>
    SettingsService(
      await ref.watch(secureStorageProvider.future),
    );
// coverage:ignore-end

class SettingsService {
  static const _etebaseAccountDataKey = 'etebase.accountData';

  final FlutterSecureStorage _secureStorage;

  SettingsService(this._secureStorage);

  Future<String?> getEtebaseAccountData() =>
      _secureStorage.read(key: _etebaseAccountDataKey);

  Future<void> setEtebaseAccountData(String accountData) =>
      _secureStorage.write(key: _etebaseAccountDataKey, value: accountData);

  Future<void> removeEtebaseAccountData(String accountData) =>
      _secureStorage.delete(key: _etebaseAccountDataKey);
}

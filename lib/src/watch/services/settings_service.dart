import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/providers/secure_storage.dart';

part 'settings_service.g.dart';

// coverage:ignore-start
@Riverpod(keepAlive: true)
Future<SettingsService> settingsService(SettingsServiceRef ref) async {
  final service = SettingsService(
    await ref.watch(secureStorageProvider.future),
  );
  await service.init();
  return service;
}
// coverage:ignore-end

class SettingsService {
  static const _initKey = '__init';
  static const _etebaseAccountDataKey = 'etebase.accountData';
  static const _etebaseServerUrlKey = 'etebase.serverUrl';

  final FlutterSecureStorage _secureStorage;

  final _logger = Logger('$SettingsService');

  SettingsService(this._secureStorage);

  @visibleForTesting
  Future<void> init() async {
    _logger.fine('Initializing secure storage');
    if (!await _secureStorage.containsKey(key: SettingsService._initKey)) {
      _logger.fine('Writing initializer key to ensure native code is up');
      await _secureStorage.write(key: SettingsService._initKey, value: '');
    }
  }

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
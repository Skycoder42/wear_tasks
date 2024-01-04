import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/secure_storage.dart';

part 'shared_preferences.g.dart';

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) async {
  final preferences = SharedPreferences(
    await ref.watch(secureStorageProvider.future),
  );
  await preferences.reload();
  return preferences;
}

class SharedPreferences {
  static Future<SharedPreferences> getInstance() =>
      throw UnsupportedError('Use riverpod to access shared preferences');

  final FlutterSecureStorage _secureStorage;

  final _valueCache = <String, String>{};

  SharedPreferences(this._secureStorage);

  Future<bool> clear() async {
    await _secureStorage.deleteAll();
    _valueCache.clear();
    return true;
  }

  Future<void> reload() async {
    _valueCache
      ..clear()
      ..addAll(await _secureStorage.readAll());
  }

  bool containsKey(String key) => _valueCache.containsKey(key);

  bool? getBool(String key) => _getJson(key) as bool?;

  double? getDouble(String key) => _getJson(key) as double?;

  int? getInt(String key) => _getJson(key) as int?;

  String? getString(String key) => _getJson(key) as String?;

  List<String>? getStringList(String key) => _getJson(key) as List<String>?;

  Future<bool> remove(String key) async {
    await _secureStorage.delete(key: key);
    _valueCache.remove(key);
    return true;
  }

  // ignore: avoid_positional_boolean_parameters
  Future<bool> setBool(String key, bool value) => _setJson(key, value);

  Future<bool> setDouble(String key, double value) => _setJson(key, value);

  Future<bool> setInt(String key, int value) => _setJson(key, value);

  Future<bool> setString(String key, String value) => _setJson(key, value);

  Future<bool> setStringList(String key, List<String> value) =>
      _setJson(key, value);

  dynamic _getJson(String key) => switch (_valueCache[key]) {
        final String value => json.decode(value),
        _ => null,
      };

  Future<bool> _setJson(String key, dynamic value) async {
    final encodedValue = json.encode(value);
    await _secureStorage.write(key: key, value: encodedValue);
    _valueCache[key] = encodedValue;
    return true;
  }
}

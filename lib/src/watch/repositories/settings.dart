import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:settings_annotation/settings_annotation.dart';

import '../../common/utils/shared_preferences.dart';

part 'settings.g.dart';

// coverage:ignore-start
@Riverpod(keepAlive: true)
Future<Settings> settings(SettingsRef ref) async => Settings(
      await ref.watch(sharedPreferencesProvider.future),
    );
// coverage:ignore-end

@SettingsGroup(root: true)
abstract class Settings with _$Settings {
  factory Settings(SharedPreferences sharedPreferences) = _$SettingsImpl;

  HiveSettings get hive;

  EtebaseSettings get etebase;
}

@SettingsGroup()
abstract class HiveSettings with _$HiveSettings {
  @SettingsEntry(
    fromSettings: _byteArrayFromSettings,
    toSettings: _byteArrayToSettings,
  )
  List<int>? get cipherKey;

  static List<int> _byteArrayFromSettings(String value) => base64.decode(value);
  static String _byteArrayToSettings(List<int> value) => base64.encode(value);
}

@SettingsGroup()
abstract class EtebaseSettings with _$EtebaseSettings {
  String? get accountData;

  @SettingsEntry(
    fromSettings: _uriFromSettings,
    toSettings: _uriToSettings,
  )
  Uri? get serverUrl;

  String? get defaultCollection;

  static Uri _uriFromSettings(String value) => Uri.parse(value);
  static String _uriToSettings(Uri uri) => uri.toString();
}

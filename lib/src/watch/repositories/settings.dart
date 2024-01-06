import 'dart:convert';

import 'package:flutter/material.dart';
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

  @SettingsEntry(
    defaultValue: LiteralDefault('const TimeOfDay(hour: 9, minute: 0)'),
    fromSettings: _timeOfDayFromSettings,
    toSettings: _timeOfDayToSettings,
  )
  TimeOfDay get defaultTime;

  static TimeOfDay _timeOfDayFromSettings(int value) {
    final d = Duration(minutes: value);
    final hours = d.inHours;
    final minutes = (d - Duration(hours: hours)).inMinutes;
    return TimeOfDay(hour: hours, minute: minutes);
  }

  static int _timeOfDayToSettings(TimeOfDay timeOfDay) =>
      Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute).inMinutes;
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

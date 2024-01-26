import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:settings_annotation/settings_annotation.dart';

import '../../common/utils/shared_preferences.dart';
import '../models/task.dart';

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

  SqlSettings get sql;

  AccountSettings get account;

  TaskSettings get tasks;
}

@SettingsGroup()
abstract class TaskSettings with _$TaskSettings {
  @SettingsEntry(
    defaultValue: LiteralDefault('const TimeOfDay(hour: 9, minute: 0)'),
    fromSettings: _timeOfDayFromSettings,
    toSettings: _timeOfDayToSettings,
  )
  TimeOfDay get defaultTime;

  @SettingsEntry(defaultValue: TaskPriority.none)
  TaskPriority get defaultPriority;

  String? get defaultCollection;

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
abstract class SqlSettings with _$SqlSettings {
  String? get cipherPassphrase;
}

@SettingsGroup()
abstract class AccountSettings with _$AccountSettings {
  String? get accountData;

  @SettingsEntry(
    fromSettings: _uriFromSettings,
    toSettings: _uriToSettings,
  )
  Uri? get serverUrl;

  static Uri _uriFromSettings(String value) => Uri.parse(value);
  static String _uriToSettings(Uri uri) => uri.toString();
}

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:flutter_gen/gen_l10n/app_localizations.dart'
    show AppLocalizations;

part 'localization.g.dart';

@Riverpod(keepAlive: true)
AppLocalizations appLocalizations(AppLocalizationsRef ref) => throw StateError(
      'appLocalizationsProvider must be overridden to be initialized',
    );

extension BuildContextX on BuildContext {
  AppLocalizations get strings => AppLocalizations.of(this);
}

extension AppLocalizationsX on AppLocalizations {
  String taskDueDescription(DateTime taskDue) {
    final now = DateTime.now();
    if (taskDue.isBefore(now)) {
      return task_due_past;
    } else if (taskDue.difference(now) < const Duration(hours: 24)) {
      return task_due_time(taskDue);
    } else {
      final nextYear = now.copyWith(year: now.year + 1);
      if (taskDue.isBefore(nextYear)) {
        return task_due_date(taskDue);
      } else {
        return task_due_year(taskDue);
      }
    }
  }
}

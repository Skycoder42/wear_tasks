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

enum _TaskDateKind {
  timeOnly,
  dateOnly,
  yearOnly,
  past,
}

extension BuildContextX on BuildContext {
  AppLocalizations get strings => AppLocalizations.of(this);
}

extension AppLocalizationsX on AppLocalizations {
  String taskDueDescription(DateTime taskDue) => _mapTaskDateTime(taskDue).$2;

  String taskEndDescription(DateTime? taskEnd) {
    final (kind, date) = _mapTaskDateTime(taskEnd);
    return task_end_date(kind.name, date);
  }

  (_TaskDateKind, String) _mapTaskDateTime(DateTime? taskDue) {
    if (taskDue == null) {
      return (_TaskDateKind.past, '');
    }

    final now = DateTime.now();
    if (taskDue.isBefore(now)) {
      return (_TaskDateKind.past, task_due_past);
    } else if (taskDue.difference(now) < const Duration(hours: 24)) {
      return (_TaskDateKind.timeOnly, task_due_time(taskDue));
    } else {
      final nextYear = now.copyWith(year: now.year + 1);
      if (taskDue.isBefore(nextYear)) {
        return (_TaskDateKind.dateOnly, task_due_date(taskDue));
      } else {
        return (_TaskDateKind.yearOnly, task_due_year(taskDue));
      }
    }
  }
}

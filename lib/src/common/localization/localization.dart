import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:flutter_gen/gen_l10n/app_localizations.dart'
    show AppLocalizations;

part 'localization.g.dart';

extension BuildContextX on BuildContext {
  AppLocalizations get strings => AppLocalizations.of(this);
}

@Riverpod(keepAlive: true)
AppLocalizations appLocalizations(AppLocalizationsRef ref) => throw StateError(
      'appLocalizationsProvider must be overridden to be initialized',
    );

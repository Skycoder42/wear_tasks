import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../watch/services/account_service.dart';
import 'localization.dart';

part 'error_localizer.g.dart';

@riverpod
ErrorLocalizer errorLocalizer(ErrorLocalizerRef ref) => ErrorLocalizer(
      ref.watch(appLocalizationsProvider),
    );

class ErrorLocalizer {
  final AppLocalizations _strings;

  ErrorLocalizer(this._strings);

  String localize(Object error) => switch (error) {
        EtebaseException(code: final code) => code.name,
        NotLoggedInException() => _strings.error_not_logged_in,
        _ => switch (error.toString().split(':')) {
            [final name, ...] => name,
            _ => error.runtimeType.toString(),
          },
      };
}

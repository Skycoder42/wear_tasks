import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/etebase_provider.dart';
import '../../../common/utils/error_stringifier.dart';
import '../../services/settings_service.dart';

part 'login_controller.g.dart';
part 'login_controller.freezed.dart';

@freezed
sealed class LoginState with _$LoginState {
  const factory LoginState.loggedOut() = LoggedOutState;
  const factory LoginState.loggingIn() = LoggingInState;
  const factory LoginState.loggedIn() = LoggedInState;
  const factory LoginState.loginFailed(String reason) = LoginFailedState;

  const LoginState._();

  bool get canLogin => switch (this) {
        LoggedOutState() || LoginFailedState() => true,
        _ => false,
      };
}

@riverpod
class LoginController extends _$LoginController {
  final _logger = Logger('$LoginController');

  @override
  LoginState build() => const LoginState.loggedOut();

  Future<void> login(String username, String password, [Uri? serverUrl]) async {
    switch (state) {
      case LoggedOutState() || LoginFailedState():
        break;
      default:
        return;
    }

    state = const LoginState.loggingIn();
    EtebaseAccount? account;
    try {
      final settings = await ref.read(settingsServiceProvider.future);
      final client = await ref.read(etebaseClientProvider(serverUrl).future);

      account = await EtebaseAccount.login(client, username, password);
      await settings.setEtebaseAccountData(await account.save());

      state = const LoginState.loggedIn();

      // ignore: avoid_catches_without_on_clauses
    } catch (error, stackTrace) {
      _logger.severe('Etebase login failed', error, stackTrace);
      state = LoginState.loginFailed(ErrorStringifier.stringify(error));
    } finally {
      await account?.dispose();
    }
  }
}

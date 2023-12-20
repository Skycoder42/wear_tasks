import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/providers/etebase_provider.dart';
import 'settings_service.dart';

part 'account_service.g.dart';

class NotLoggedInException implements Exception {
  final Object? innerException;
  final StackTrace? innerStackTrace;

  NotLoggedInException([this.innerException, this.innerStackTrace]);

  @override
  String toString() => 'Not logged in';
}

@riverpod
EtebaseAccount etebaseAccount(EtebaseAccountRef ref) =>
    switch (ref.watch(accountServiceProvider)) {
      AsyncData(value: final EtebaseAccount account) => account,
      AsyncError(error: final e, stackTrace: final s) =>
        throw NotLoggedInException(e, s),
      _ => throw NotLoggedInException(),
    };

@Riverpod(keepAlive: true)
class AccountService extends _$AccountService {
  final _logger = Logger('$AccountService');

  @override
  Future<EtebaseAccount?> build() async {
    _logger.finer('Restoring account');
    final settings = await ref.watch(settingsServiceProvider.future);
    final accountData = await settings.getEtebaseAccountData();
    if (accountData == null) {
      _logger.fine('No account data in secure store');
      return null;
    }

    final serverUrl = await settings.getEtebaseServerUrl();
    _logger.finer('Creating client for server: $serverUrl');
    final client = await ref.watch(etebaseClientProvider(serverUrl).future);
    _logger.finer('Restoring account from persisted data');
    final account = await EtebaseAccount.restore(client, accountData);
    ref.onDispose(account.dispose);

    _logger.info('Successfully restored account!');
    return account;
  }

  Future<void> login(String username, String password, [Uri? serverUrl]) async {
    final oldAccount = await future.catchError((_) => null);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      EtebaseAccount? account;
      try {
        await oldAccount?.logout();

        final settings = await ref.watch(settingsServiceProvider.future);
        final client = await ref.watch(etebaseClientProvider(serverUrl).future);

        account = await EtebaseAccount.login(client, username, password);
        await settings.setEtebaseAccountData(await account.save());

        ref.onDispose(account.dispose);
        return account;

        // ignore: avoid_catches_without_on_clauses
      } catch (error, stackTrace) {
        _logger.severe('Etebase login failed', error, stackTrace);
        await account?.dispose();
        rethrow;
      }
    });
  }

  Future<void> logout() async {
    final settings = await ref.read(settingsServiceProvider.future);
    await settings.removeEtebaseAccountData();
    await settings.removeEtebaseServerUrl();
    await state.valueOrNull?.logout();
    ref.invalidateSelf();
  }
}

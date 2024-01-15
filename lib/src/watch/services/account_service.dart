import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/providers/etebase_provider.dart';
import '../repositories/settings.dart';

part 'account_service.g.dart';

class NotLoggedInException implements Exception {
  @override
  String toString() => 'NotLoggedInException: The app is not logged in.';
}

@Riverpod(keepAlive: true)
Future<EtebaseAccount> etebaseAccount(EtebaseAccountRef ref) async {
  final account = await ref.watch(accountServiceProvider.future);
  if (account != null) {
    return account;
  } else {
    throw NotLoggedInException();
  }
}

@Riverpod(keepAlive: true)
class AccountService extends _$AccountService {
  final _logger = Logger('$AccountService');

  @override
  Future<EtebaseAccount?> build() async {
    _logger.fine('Restoring account');
    final settings = await ref.watch(settingsProvider.future);
    final accountData = settings.account.accountData;
    if (accountData == null) {
      _logger.info('No account data in secure storage');
      return null;
    }

    final serverUrl = settings.account.serverUrl;
    _logger.fine('Creating client for server: $serverUrl');
    final client = await ref.watch(etebaseClientProvider(serverUrl).future);
    _logger.fine('Restoring account from persisted data');
    final account = await EtebaseAccount.restore(client, accountData);
    ref.onDispose(account.dispose);

    _logger.info('Successfully restored account form secure storage');
    return account;
  }

  Future<void> login(String username, String password, [Uri? serverUrl]) async {
    _logger.fine('Waiting for pending operations to finish');
    final oldAccount = await future.catchError((_) => null);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      EtebaseAccount? account;
      try {
        _logger.fine('Logging out of previous account, if present');
        await oldAccount?.logout();

        _logger.fine('Creating client for server: $serverUrl');
        final settings = await ref.watch(settingsProvider.future);
        final client = await ref.watch(etebaseClientProvider(serverUrl).future);

        _logger.fine('Logging in for account $username');
        account = await EtebaseAccount.login(client, username, password);

        _logger.fine('Persisting account data to secure storage');
        await settings.account.setAccountData(await account.save());

        _logger.info('Successfully logged in');
        ref.onDispose(account.dispose);
        return account;

        // ignore: avoid_catches_without_on_clauses
      } catch (error, stackTrace) {
        _logger.severe('Login failed', error, stackTrace);
        await account?.dispose();
        rethrow;
      }
    });
  }

  Future<void> logout() async {
    _logger.fine('Logging out of previous account, if present');
    await future.then((account) async => account?.logout(), onError: (_) {});

    _logger.fine('Deleting account data from secure storage');
    final settings = await ref.read(settingsProvider.future);
    await settings.account.removeAccountData();
    await settings.account.removeServerUrl();

    _logger.fine('Invalidating provider');
    ref.invalidateSelf();

    _logger.info('Successfully logged out');
  }
}

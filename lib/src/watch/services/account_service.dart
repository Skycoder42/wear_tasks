import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/providers/etebase_provider.dart';
import 'settings_service.dart';

part 'account_service.g.dart';

@Riverpod(keepAlive: true)
class AccountService extends _$AccountService {
  @override
  Future<EtebaseAccount?> build() async {
    final settings = await ref.watch(settingsServiceProvider.future);
    final accountData = await settings.getEtebaseAccountData();
    if (accountData == null) {
      return null;
    }

    final serverUrl = await settings.getEtebaseServerUrl();
    final client = await ref.watch(etebaseClientProvider(serverUrl).future);
    final account = await EtebaseAccount.restore(client, accountData);
    ref.onDispose(account.dispose);

    return account;
  }
}

import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package_info_provider.dart';

part 'etebase_provider.g.dart';

@Riverpod(keepAlive: true)
Future<Uri> etebaseDefaultServerUrl(EtebaseDefaultServerUrlRef ref) =>
    etebaseGetDefaultServerUrl();

@Riverpod(keepAlive: true)
Future<EtebaseClient> etebaseClient(
  EtebaseClientRef ref,
  Uri? serverUrl,
) async {
  final packageInfo = await ref.watch(packageInfoProvider.future);
  final client = await EtebaseClient.create(packageInfo.packageName, serverUrl);
  ref.onDispose(client.dispose);
  return client;
}

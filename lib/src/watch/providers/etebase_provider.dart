import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package_info_provider.dart';

part 'etebase_provider.g.dart';

@riverpod
Future<Uri> etebaseDefaultServerUrl(EtebaseDefaultServerUrlRef ref) =>
    etebaseGetDefaultServerUrl();

@riverpod
Future<EtebaseClient> etebaseClient(EtebaseClientRef ref, Uri serverUrl) async {
  final packageInfo = await ref.watch(packageInfoProvider.future);
  return EtebaseClient.create(
    packageInfo.packageName,
    serverUrl,
  );
}

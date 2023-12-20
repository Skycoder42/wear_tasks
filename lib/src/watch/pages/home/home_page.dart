import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../services/account_service.dart';
import '../../widgets/watch_scaffold.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => WatchScaffold(
        title: const Text('Home'),
        body: Center(
          child: Text(
            ref.watch(etebaseAccountProvider).toString(),
          ),
        ),
      );
}

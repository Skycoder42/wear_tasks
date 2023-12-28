import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/router/watch_router.dart';
import '../../widgets/watch_scaffold.dart';
import '../create_task/create_task_page.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => WatchScaffold(
        body: Center(
          child: Hero(
            tag: CreateTaskPage.createButtonHeroTag,
            child: FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create Task'),
              onPressed: () => const CreateTaskRoute().go(context),
            ),
          ),
        ),
      );
}

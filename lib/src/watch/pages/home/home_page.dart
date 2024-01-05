import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/localization/localization.dart';
import '../../app/router/watch_router.dart';
import '../../widgets/watch_scaffold.dart';
import '../create_task/create_task_page.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => WatchScaffold(
        horizontalSafeArea: true,
        body: ListView(
          children: [
            Hero(
              tag: CreateTaskPage.createButtonHeroTag,
              child: FilledButton.icon(
                icon: const Icon(Icons.add),
                label: Text(context.strings.home_page_create_task),
                onPressed: () => const CreateTaskRoute().go(context),
              ),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.upload),
              label: Text(context.strings.home_page_retry_uploads),
              onPressed: () {},
            ),
          ],
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/extensions/riverpod_extensions.dart';
import '../../../common/localization/localization.dart';
import '../../app/router/watch_router.dart';
import '../../services/retry_uploads_service.dart';
import '../../widgets/side_button.dart';
import '../../widgets/watch_scaffold.dart';
import '../create_task/create_task_page.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listenForErrors(context, retryUploadsServiceProvider);

    return WatchScaffold(
      horizontalSafeArea: true,
      loadingOverlayActive:
          ref.watch(retryUploadsServiceProvider.select(_isLoading)),
      leftAction: SideButton(
        icon: const Icon(Icons.settings),
        onPressed: () => const SettingsRoute().go(context),
      ),
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
          if (ref.watch(retryUploadsServiceProvider.select(_hasPending)))
            OutlinedButton.icon(
              icon: const Icon(Icons.upload),
              label: Text(context.strings.home_page_retry_uploads),
              onPressed: () async => ref
                  .read(retryUploadsServiceProvider.notifier)
                  .uploadPending(),
            ),
        ],
      ),
    );
  }

  bool _isLoading(AsyncValue<RetryUploadsState> value) => switch (value) {
        AsyncData(value: UploadingRetryState()) => true,
        _ => false,
      };

  bool _hasPending(AsyncValue<RetryUploadsState> value) => switch (value) {
        AsyncData(value: HasPendingUploadsRetryState()) => true,
        _ => false,
      };
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/localization/error_localizer.dart';
import '../../../common/localization/localization.dart';
import '../../../common/providers/uuid_provider.dart';
import '../../../common/widgets/error_snack_bar.dart';
import '../../../common/widgets/success_snack_bar.dart';
import '../../models/task.dart';
import '../../widgets/watch_scaffold.dart';
import 'collection_infos.dart';
import 'collection_selector_button.dart';
import 'create_task_service.dart';

class CreateTaskPage extends HookConsumerWidget {
  static const createButtonHeroTag = 'CreateTaskPage.createButtonHero';

  const CreateTaskPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionInfos = ref.watch(collectionInfosProvider);

    ref
      ..listen(
        collectionInfosProvider.select((value) => value.error),
        (_, error) {
          if (error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                context: context,
                content: Text(ref.read(errorLocalizerProvider).localize(error)),
              ),
            );
          }
        },
      )
      ..listen(createTaskServiceProvider, (_, state) {
        switch (state) {
          case CreateTaskSavedState():
            ScaffoldMessenger.of(context).showSnackBar(
              SuccessSnackBar(
                context: context,
                content: Text(context.strings.create_task_page_success_message),
              ),
            );
            Navigator.pop(context);
          case CreateTaskFailedState(error: final error):
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                context: context,
                content: Text(ref.read(errorLocalizerProvider).localize(error)),
              ),
            );
        }
      });

    final currentCollection = useState('1'); // TODO load from settings
    return WatchScaffold(
      loadingOverlayActive: collectionInfos.isLoading ||
          ref.watch(createTaskServiceProvider).isSaving,
      rightAction: collectionInfos.hasValue
          ? CollectionSelectorButton(
              collections: collectionInfos.requireValue,
              currentCollection: currentCollection.value,
              onCollectionSelected: (uid) => currentCollection.value = uid,
            )
          : null,
      bottomAction: Hero(
        tag: createButtonHeroTag,
        child: FilledButton(
          child: const Icon(Icons.add),
          onPressed: () async => _createTask(ref, currentCollection.value),
        ),
      ),
      body: const SafeArea(
        child: Column(),
      ),
    );
  }

  Future<void> _createTask(WidgetRef ref, String collectionUid) async {
    final task = Task(
      uid: ref.read(uuidProvider).v4(),
      createdAt: DateTime.now(),
      summary: 'TODO',
    );

    final taskService = ref.read(createTaskServiceProvider.notifier);

    await taskService.createTask(collectionUid, task);
  }
}

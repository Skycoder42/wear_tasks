import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/extensions/riverpod_extensions.dart';
import '../../../common/localization/error_localizer.dart';
import '../../../common/localization/localization.dart';
import '../../../common/providers/uuid_provider.dart';
import '../../../common/widgets/error_snack_bar.dart';
import '../../../common/widgets/success_snack_bar.dart';
import '../../models/task.dart';
import '../../widgets/submit_form.dart';
import '../../widgets/watch_scaffold.dart';
import 'active_collection.dart';
import 'collection_infos.dart';
import 'collection_selector_button.dart';
import 'create_task_service.dart';

class CreateTaskPage extends HookConsumerWidget {
  static const _summaryKey = 'summary';

  static const createButtonHeroTag = 'CreateTaskPage.createButtonHero';

  const CreateTaskPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionInfos = ref.watch(collectionInfosProvider);
    final activeCollection = ref.watch(activeCollectionProvider);
    final createTaskState = ref.watch(createTaskServiceProvider);
    final isProcessing = collectionInfos.isLoading ||
        activeCollection.isLoading ||
        createTaskState.isSaving;

    ref
      ..listenForErrors(context, collectionInfosProvider)
      ..listenForErrors(context, activeCollectionProvider)
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

    return SubmitForm(
      onValidationFailed: () {},
      onSubmit: (result) async => _createTask(
        ref,
        activeCollection.requireValue,
        result[_summaryKey] as String,
      ),
      builder: (context, onSaved, onSubmit) => WatchScaffold(
        loadingOverlayActive: isProcessing,
        rightAction: collectionInfos.hasValue && activeCollection.hasValue
            ? CollectionSelectorButton(
                collections: collectionInfos.requireValue,
                currentCollection: activeCollection.requireValue,
                onCollectionSelected: (uid) async =>
                    ref.read(activeCollectionProvider.notifier).setActive(uid),
              )
            : null,
        bottomAction: Hero(
          tag: createButtonHeroTag,
          child: FilledButton(
            onPressed: onSubmit,
            child: const Icon(Icons.add),
          ),
        ),
        horizontalSafeArea: true,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  enabled: !isProcessing,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    label: Text(context.strings.create_task_page_summary_label),
                  ),
                  validator: (value) => _validateNotNullOrEmpty(context, value),
                  onSaved: (newValue) => onSaved(_summaryKey, newValue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createTask(
    WidgetRef ref,
    String collectionUid,
    String summary,
  ) async {
    final task = Task(
      collectionUid: collectionUid,
      taskUid: ref.read(uuidProvider).v4(),
      createdAt: DateTime.now(),
      summary: summary,
    );

    final taskService = ref.read(createTaskServiceProvider.notifier);
    await taskService.createTask(task);
  }

  String? _validateNotNullOrEmpty(BuildContext context, String? value) =>
      (value?.isEmpty ?? true) ? context.strings.validator_not_empty : null;
}

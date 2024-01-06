import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/extensions/riverpod_extensions.dart';
import '../../../common/localization/error_localizer.dart';
import '../../../common/localization/localization.dart';
import '../../../common/providers/uuid_provider.dart';
import '../../../common/widgets/error_snack_bar.dart';
import '../../../common/widgets/success_snack_bar.dart';
import '../../app/router/watch_router.dart';
import '../../models/task.dart';
import '../../models/task_recurrence.dart';
import '../../services/create_task_service.dart';
import '../../widgets/submit_form.dart';
import '../../widgets/watch_scaffold.dart';
import 'collection_selection/active_collection.dart';
import 'collection_selection/collection_infos.dart';
import 'collection_selection/collection_selector_button.dart';
import 'priority_button.dart';

class CreateTaskPage extends HookConsumerWidget {
  static const _summaryKey = 'summary';
  static const _descriptionKey = 'description';

  static const createButtonHeroTag = 'CreateTaskPage.createButtonHero';

  const CreateTaskPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialDueDate = useMemoized(() {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day + 1, 9);
    });
    final currentDueDate = useState(initialDueDate);
    final currentRecurrence = useState<TaskRecurrence?>(null);
    final currentPriority = useState(TaskPriority.none);

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
          case CreateTaskSavedState(didUpload: true):
            ScaffoldMessenger.of(context).showSnackBar(
              SuccessSnackBar(
                context: context,
                content: Text(context.strings.create_task_page_success_message),
              ),
            );
            Navigator.pop(context);
          case CreateTaskSavedState(didUpload: false):
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                context: context,
                content: Text(
                  context.strings.create_task_page_upload_failed_message,
                ),
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
        currentDueDate.value,
        currentRecurrence.value,
        currentPriority.value,
        result[_descriptionKey] as String?,
      ),
      builder: (context, onSaved, onSubmit) => WatchScaffold(
        loadingOverlayActive: isProcessing,
        leftAction: PriorityButton(
          currentPriority: currentPriority.value,
          onPriorityChanged: (p) => currentPriority.value = p,
        ),
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
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    enabled: !isProcessing,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      label:
                          Text(context.strings.create_task_page_summary_label),
                    ),
                    validator: (value) =>
                        _validateNotNullOrEmpty(context, value),
                    onSaved: (newValue) => onSaved(_summaryKey, newValue),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: currentRecurrence.value != null
                        ? const Icon(Icons.event_repeat)
                        : const Icon(Icons.event),
                    label: Text(
                      context.strings.taskDueDescription(currentDueDate.value),
                    ),
                    onPressed: () async {
                      final result = await DateTimeSelectionRoute.from(
                        currentDueDate.value,
                        currentRecurrence.value,
                      ).push<(DateTime, TaskRecurrence?)>(context);
                      if (result case (final dateTime, final recurrence)) {
                        currentDueDate.value = dateTime;
                        currentRecurrence.value = recurrence;
                      }
                    },
                  ),
                  TextFormField(
                    enabled: !isProcessing,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      label: Text(
                        context.strings.create_task_page_description_label,
                      ),
                    ),
                    onSaved: (newValue) => onSaved(_descriptionKey, newValue),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
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
    DateTime dueDate,
    TaskRecurrence? recurrence,
    TaskPriority priority,
    String? description,
  ) async {
    final task = Task(
      collectionUid: collectionUid,
      taskUid: ref.read(uuidProvider).v4(),
      createdAt: dueDate,
      recurrence: recurrence,
      summary: summary,
      priority: priority,
      description: (description?.isEmpty ?? true) ? null : description,
    );

    final taskService = ref.read(createTaskServiceProvider.notifier);
    await taskService.createTask(task);
  }

  String? _validateNotNullOrEmpty(BuildContext context, String? value) =>
      (value?.isEmpty ?? true) ? context.strings.validator_not_empty : null;
}

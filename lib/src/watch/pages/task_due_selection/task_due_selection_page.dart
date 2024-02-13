import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/extensions/riverpod_extensions.dart';
import '../../../common/localization/localization.dart';
import '../../app/router/watch_router.dart';
import '../../app/watch_theme.dart';
import '../../models/task_recurrence.dart';
import '../../widgets/hooks/rotary_scroll_controller_hook.dart';
import '../../widgets/watch_dialog.dart';
import '../date_time_picker/date_time_picker_page.dart';
import 'task_due_selection_controller.dart';

class TaskDueSelectionPage extends HookConsumerWidget {
  final DateTime initialDateTime;
  final TaskRecurrence? initialRecurrence;

  const TaskDueSelectionPage({
    super.key,
    required this.initialDateTime,
    required this.initialRecurrence,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskDueSelectionState = ref.watch(taskDueSelectionControllerProvider);
    final currentDateTime = useState(
      initialDateTime.copyWith(second: 0, millisecond: 0, microsecond: 0),
    );
    final currentRecurrence = useState<TaskRecurrence?>(initialRecurrence);
    final scrollController = useRotaryScrollController(ref);

    ref.listenForErrors(context, taskDueSelectionControllerProvider);

    return WatchDialog<(DateTime, TaskRecurrence?)>(
      horizontalSafeArea: true,
      onAccept: () => (currentDateTime.value, currentRecurrence.value),
      loadingOverlayActive: taskDueSelectionState is AsyncLoading,
      body: ListView(
        controller: scrollController,
        children: [
          const SizedBox(width: double.infinity),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.watch_later),
              label: Text(context.strings.task_due_time(currentDateTime.value)),
              onPressed: () async {
                final newTime = await DateTimePickerRoute(
                  mode: DateTimePickerMode.timeOnly,
                  currentDateTime.value,
                ).push<DateTime>(context);
                if (newTime != null) {
                  currentDateTime.value = currentDateTime.value.copyWith(
                    hour: newTime.hour,
                    minute: newTime.minute,
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.event),
              label: Text(
                context.strings.task_due_date_full(currentDateTime.value),
              ),
              onPressed: () async {
                final newDate = await DateTimePickerRoute(
                  mode: DateTimePickerMode.dateOnly,
                  currentDateTime.value,
                ).push<DateTime>(context);
                if (newDate != null) {
                  currentDateTime.value = currentDateTime.value.copyWith(
                    year: newDate.year,
                    month: newDate.month,
                    day: newDate.day,
                  );
                }
              },
            ),
          ),
          Center(
            child: IconButton(
              color: currentRecurrence.value != null
                  ? context.theme.colorScheme.primary
                  : null,
              icon: Icon(
                currentRecurrence.value != null
                    ? Icons.repeat_on
                    : Icons.repeat,
              ),
              onPressed: () async {
                currentRecurrence.value =
                    await RecurrenceSelectionRoute(currentRecurrence.value)
                        .push<TaskRecurrence>(context);
              },
            ),
          ),
          if (taskDueSelectionState
              case AsyncData(
                value: TaskDueSelectionState(
                  expressions: final expressions,
                  defaultTime: final defaultTime,
                )
              ) when expressions.isNotEmpty) ...[
            const Divider(),
            for (final expression in expressions)
              ListTile(
                title: Text(expression.description(context.strings)),
                onTap: () => Navigator.pop(
                  context,
                  (
                    expression.apply(DateTime.now(), defaultTime),
                    expression.recurrence,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<DateTime>('initialDateTime', initialDateTime))
      ..add(
        DiagnosticsProperty<TaskRecurrence?>(
          'initialRecurrence',
          initialRecurrence,
        ),
      );
  }
}

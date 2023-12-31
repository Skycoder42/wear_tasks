import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/localization/localization.dart';
import '../../app/watch_theme.dart';
import '../../models/task_recurrence.dart';
import '../../widgets/watch_dialog.dart';

class RecurrencePickerPage extends HookConsumerWidget {
  final TaskRecurrence? initialRecurrence;

  const RecurrencePickerPage({
    super.key,
    required this.initialRecurrence,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialScrollOffset = 42.0 *
        max(
          0,
          (initialRecurrence?.frequency.index ??
                  RecurrenceFrequency.daily.index) -
              1,
        );
    final frequencyController = useScrollController(
      initialScrollOffset: initialScrollOffset,
    );
    final selectedFrequency = useState(initialRecurrence?.frequency);

    return WatchDialog<TaskRecurrence?>(
      horizontalSafeArea: true,
      canAccept: selectedFrequency.value != null,
      onReject: () => initialRecurrence,
      onAccept: () => selectedFrequency.value != null
          ? TaskRecurrence(
              frequency: selectedFrequency.value!,
            )
          : null,
      bottomAction: Theme(
        data: ref.watch(
          watchThemeProvider(context.theme.colorScheme.error),
        ),
        child: ElevatedButton(
          child: const Icon(Icons.delete_forever),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        controller: frequencyController,
        children: [
          for (final frequency in RecurrenceFrequency.values)
            RadioListTile<RecurrenceFrequency>(
              toggleable: true,
              title: Text(
                context.strings.recurrence_selection_page_frequency(
                  frequency.name,
                ),
              ),
              value: frequency,
              groupValue: selectedFrequency.value,
              onChanged: (value) => selectedFrequency.value = value,
            ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<TaskRecurrence>(
        'initialRecurrence',
        initialRecurrence,
      ),
    );
  }
}

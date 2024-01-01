import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/localization/localization.dart';
import '../../app/watch_theme.dart';
import '../../models/task_recurrence.dart';
import '../../widgets/watch_dialog.dart';

class RecurrencePickerPage extends HookConsumerWidget {
  final TaskRecurrence? initialRecurrence;

  late final _initialScrollOffset = 42.0 *
      max(
        0,
        (initialRecurrence?.frequency.index ??
                RecurrenceFrequency.daily.index) -
            1,
      );

  RecurrencePickerPage({
    super.key,
    required this.initialRecurrence,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frequencyController = useScrollController(
      initialScrollOffset: _initialScrollOffset,
    );
    final intervalController = useTextEditingController(
      text: (initialRecurrence?.interval ?? 1).toString(),
    );
    final intervalFocus = useFocusNode();
    final countController = useTextEditingController(
      text: (initialRecurrence?.count ?? 1).toString(),
    );
    final countFocus = useFocusNode();

    final selectedFrequency = useState(initialRecurrence?.frequency);
    final selectedInterval = useState(initialRecurrence?.interval ?? 1);
    final selectedCount = useState(initialRecurrence?.count ?? 0);

    final pageValidations = useMemoized(
      () => [
        selectedFrequency.value != null,
        selectedInterval.value >= 1 && (selectedCount.value >= 0),
      ],
      [selectedFrequency.value, selectedInterval.value, selectedCount.value],
    );

    return WatchDialog<TaskRecurrence?>.paged(
      horizontalSafeArea: true,
      onReject: () => initialRecurrence,
      onAccept: () => selectedFrequency.value != null
          ? TaskRecurrence(
              frequency: selectedFrequency.value!,
              interval: selectedInterval.value,
              count: selectedCount.value == 0 ? null : selectedCount.value,
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
      pageValidations: pageValidations,
      pages: [
        ListView(
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
        ListView(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              onTap: intervalFocus.requestFocus,
              title: Text(
                textAlign: TextAlign.center,
                context.strings.recurrence_selection_page_interval(
                  selectedInterval.value,
                  selectedFrequency.value?.name ?? '',
                ),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              onTap: countFocus.requestFocus,
              title: Text(
                textAlign: TextAlign.center,
                context.strings.recurrence_selection_page_count(
                  selectedCount.value,
                ),
              ),
            ),
            ListTile(
              title: const Center(child: Icon(Icons.settings_backup_restore)),
              onTap: () {
                selectedInterval.value = 1;
                selectedCount.value = 0;
              },
            ),
            Offstage(
              child: TextField(
                controller: intervalController,
                focusNode: intervalFocus,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp('^[1-9][0-9]*'),
                  ),
                ],
                onChanged: (value) {
                  selectedInterval.value = int.tryParse(value) ?? 1;
                },
              ),
            ),
            Offstage(
              child: TextField(
                controller: countController,
                focusNode: countFocus,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp('^[0-9]*'),
                  ),
                ],
                onChanged: (value) {
                  selectedCount.value = int.tryParse(value) ?? 0;
                },
              ),
            ),
          ],
        ),
      ],
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

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/localization/localization.dart';
import '../../app/router/watch_router.dart';
import '../../app/watch_theme.dart';
import '../../models/task_recurrence.dart';
import '../../widgets/hooks/rotary_scroll_controller_hook.dart';
import '../../widgets/side_button.dart';
import '../../widgets/watch_dialog.dart';
import '../../widgets/watch_scrollbar.dart';

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
    final activePage = useState(0);
    final updateActivePage = useCallback(
      // ignore: avoid_types_on_closure_parameters
      (int value) => activePage.value = value,
      [activePage],
    );
    final frequencyController = useRotaryScrollController(
      initialScrollOffset: _initialScrollOffset,
      enabled: activePage.value == 0,
    );
    final recurrenceController = useRotaryScrollController(
      enabled: activePage.value == 1,
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
    final selectedEndMode = useState(
      initialRecurrence?.endMode ?? RecurrenceEndMode.infinite,
    );
    final selectedCount = useState(initialRecurrence?.count ?? 1);
    final selectedEndDate = useState<DateTime?>(initialRecurrence?.endDate);

    final pageValidations = useMemoized(
      () => [
        selectedFrequency.value != null,
        selectedInterval.value >= 1 &&
            switch (selectedEndMode.value) {
              RecurrenceEndMode.infinite => true,
              RecurrenceEndMode.count => selectedCount.value >= 1,
              RecurrenceEndMode.endDate => selectedEndDate.value != null,
            },
      ],
      [
        selectedFrequency.value,
        selectedInterval.value,
        selectedEndMode.value,
        selectedCount.value,
        selectedEndDate.value,
      ],
    );

    return WatchDialog<TaskRecurrence?>.paged(
      horizontalSafeArea: true,
      onReject: () => initialRecurrence,
      onAccept: () => selectedFrequency.value != null
          ? TaskRecurrence(
              frequency: selectedFrequency.value!,
              interval: selectedInterval.value,
              count: selectedEndMode.value == RecurrenceEndMode.count
                  ? selectedCount.value
                  : null,
              endDate: selectedEndMode.value == RecurrenceEndMode.endDate
                  ? selectedEndDate.value
                  : null,
            )
          : null,
      onPageChanged: updateActivePage,
      bottomActionBuilder: (context, page) => Theme(
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
        WatchScrollbar(
          controller: frequencyController,
          child: ListView(
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
        ),
        WatchScrollbar(
          controller: recurrenceController,
          child: ListView(
            controller: recurrenceController,
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
              RadioListTile(
                value: RecurrenceEndMode.infinite,
                groupValue: selectedEndMode.value,
                onChanged: (value) => selectedEndMode.value = value!,
                title: Text(
                  context.strings.recurrence_selection_page_end_infinite,
                ),
              ),
              RadioListTile(
                value: RecurrenceEndMode.count,
                groupValue: selectedEndMode.value,
                onChanged: (value) {
                  countFocus.requestFocus();
                  selectedEndMode.value = value!;
                },
                title: Text(
                  context.strings.recurrence_selection_page_end_count(
                    selectedCount.value,
                  ),
                ),
                secondary: AnimatedOpacity(
                  opacity:
                      selectedEndMode.value == RecurrenceEndMode.count ? 1 : 0,
                  duration: WatchDialog.animationDuration,
                  curve: WatchDialog.animationCurve,
                  child: SideButton(
                    icon: const Icon(Icons.edit),
                    onPressed: countFocus.requestFocus,
                  ),
                ),
              ),
              RadioListTile(
                value: RecurrenceEndMode.endDate,
                groupValue: selectedEndMode.value,
                onChanged: (value) async {
                  final endDateTime = await DateTimePickerRoute(
                    selectedEndDate.value ?? DateTime.now(),
                  ).push<DateTime>(context);
                  if (endDateTime != null) {
                    selectedEndDate.value = endDateTime;
                    selectedEndMode.value = value!;
                  }
                },
                title: Text(
                  context.strings.taskEndDescription(selectedEndDate.value),
                ),
                secondary: AnimatedOpacity(
                  opacity: selectedEndMode.value == RecurrenceEndMode.endDate
                      ? 1
                      : 0,
                  duration: WatchDialog.animationDuration,
                  curve: WatchDialog.animationCurve,
                  child: SideButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final endDateTime = await DateTimePickerRoute(
                        selectedEndDate.value ?? DateTime.now(),
                      ).push<DateTime>(context);
                      if (endDateTime != null) {
                        selectedEndDate.value = endDateTime;
                      }
                    },
                  ),
                ),
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
                      RegExp('^[1-9][0-9]*'),
                    ),
                  ],
                  onChanged: (value) {
                    selectedCount.value = int.tryParse(value) ?? 1;
                  },
                ),
              ),
            ],
          ),
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

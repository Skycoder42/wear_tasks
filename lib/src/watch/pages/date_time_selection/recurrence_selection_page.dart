import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../models/task_recurrence.dart';
import '../../widgets/side_button.dart';
import '../../widgets/watch_dialog.dart';

class RecurrenceSelectionPage extends HookWidget {
  final TaskRecurrence? initialRecurrence;

  const RecurrenceSelectionPage({
    super.key,
    required this.initialRecurrence,
  });

  @override
  Widget build(BuildContext context) {
    final selectedFrequency = useState(initialRecurrence?.frequency);

    return WatchDialog<TaskRecurrence?>(
      horizontalSafeArea: true,
      onReject: () => initialRecurrence,
      onAccept: () => selectedFrequency.value != null
          ? TaskRecurrence(
              frequency: selectedFrequency.value!,
            )
          : null,
      bottomAction: Center(
        child: SideButton(
          icon: const Icon(Icons.delete_forever_outlined),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 4,
                children: [
                  for (final frequency in RecurrenceFrequency.values)
                    ChoiceChip(
                      label: Text(frequency.name),
                      selected: selectedFrequency.value == frequency,
                      onSelected: (value) {
                        if (value) {
                          selectedFrequency.value = frequency;
                        } else {
                          selectedFrequency.value = null;
                        }
                      },
                    ),
                ],
              ),
              // Expanded(
              //   child: ListView(
              //     controller: controller,
              //     scrollDirection: Axis.horizontal,
              //     children: [
              //       for (final frequency in RecurrenceFrequency.values)
              //         ChoiceChip(
              //           label: Text(frequency.name),
              //           selected: selectedFrequency.value == frequency,
              //           onSelected: (value) {
              //             if (value) {
              //               selectedFrequency.value = frequency;
              //             } else {
              //               selectedFrequency.value = null;
              //             }
              //           },
              //         ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
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

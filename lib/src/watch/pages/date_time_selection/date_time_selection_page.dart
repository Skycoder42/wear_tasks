import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/localization/localization.dart';
import '../../app/router/watch_router.dart';
import '../../widgets/watch_dialog.dart';

class DateTimeSelectionPage extends HookConsumerWidget {
  final DateTime initialDateTime;

  const DateTimeSelectionPage({
    super.key,
    required this.initialDateTime,
  });

  // Date
  // Time
  // (Loop)
  // predefined Expressions

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDateTime = useState(
      initialDateTime.copyWith(second: 0, millisecond: 0, microsecond: 0),
    );

    return WatchDialog<DateTime>(
      onAccept: () => currentDateTime.value,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(width: double.infinity),
              ElevatedButton(
                onPressed: () async {
                  final newTime = await TimePickerRoute(currentDateTime.value)
                      .push<TimeOfDay>(context);
                  if (newTime != null) {
                    currentDateTime.value = currentDateTime.value.copyWith(
                      hour: newTime.hour,
                      minute: newTime.minute,
                    );
                  }
                },
                child:
                    Text(context.strings.task_due_time(currentDateTime.value)),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final newDate = await DatePickerRoute(currentDateTime.value)
                      .push<DateTime>(context);
                  if (newDate != null) {
                    currentDateTime.value = currentDateTime.value.copyWith(
                      year: newDate.year,
                      month: newDate.month,
                      day: newDate.day,
                    );
                  }
                },
                child: Text(
                  context.strings.task_due_date_full(currentDateTime.value),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.event_repeat),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<DateTime>('initialDateTime', initialDateTime));
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../widgets/side_button.dart';
import '../../widgets/watch_dialog.dart';
import 'date_picker.dart';
import 'date_time_controller.dart';
import 'time_picker.dart';

enum DateTimePickerMode {
  dateTime(true, true),
  dateOnly(true, false),
  timeOnly(false, true);

  final bool hasDate;
  final bool hasTime;

  const DateTimePickerMode(this.hasDate, this.hasTime);
}

class DateTimePickerPage extends HookConsumerWidget {
  final DateTime initialDateTime;
  final DateTimePickerMode mode;

  const DateTimePickerPage({
    super.key,
    required this.initialDateTime,
    this.mode = DateTimePickerMode.dateTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateTimeController = ref.watch(dateTimeControllerProvider.notifier);

    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => dateTimeController.initialize(initialDateTime),
        );
        return null;
      },
      const [],
    );

    return WatchDialog<DateTime>.paged(
      horizontalSafeArea: true,
      bottomActionBuilder: (context, page) => Center(
        child: SideButton(
          icon: const Icon(Icons.today),
          onPressed: () {
            switch (page) {
              case 0 when mode == DateTimePickerMode.dateTime:
              case 0 when mode == DateTimePickerMode.dateOnly:
                dateTimeController.resetDate();
              case 0 when mode == DateTimePickerMode.timeOnly:
              case 1:
                dateTimeController.resetTime();
            }
          },
        ),
      ),
      onAccept: () => ref.read(dateTimeControllerProvider),
      pages: [
        if (mode.hasDate) const DatePicker(),
        if (mode.hasTime) const TimePicker(),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<DateTime>('initialDate', initialDateTime))
      ..add(EnumProperty<DateTimePickerMode>('mode', mode));
  }
}

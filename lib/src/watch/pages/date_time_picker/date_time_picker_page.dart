import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../widgets/side_button.dart';
import '../../widgets/watch_dialog.dart';
import 'date_picker.dart';
import 'time_picker.dart';

enum DateTimePickerMode {
  dateTime(true, true),
  dateOnly(true, false),
  timeOnly(false, true);

  final bool hasDate;
  final bool hasTime;

  const DateTimePickerMode(this.hasDate, this.hasTime);
}

class DateTimePickerPage extends HookWidget {
  final DateTime initialDateTime;
  final DateTimePickerMode mode;

  const DateTimePickerPage({
    super.key,
    required this.initialDateTime,
    this.mode = DateTimePickerMode.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    final currentDateTime = useState(
      TimePicker.toIntervalTime(initialDateTime),
    );

    return WatchDialog<DateTime>.paged(
      horizontalSafeArea: true,
      bottomActionBuilder: (context, page) => Center(
        child: SideButton(
          icon: const Icon(Icons.today),
          onPressed: () {
            final now = TimePicker.toIntervalTime(DateTime.now());
            switch (page) {
              case 0:
                currentDateTime.value = currentDateTime.value.copyWith(
                  year: now.year,
                  month: now.month,
                  day: now.day,
                );
              case 1:
                currentDateTime.value = currentDateTime.value.copyWith(
                  hour: now.hour,
                  minute: now.minute,
                );
            }
          },
        ),
      ),
      onAccept: () => currentDateTime.value,
      pages: [
        if (mode.hasDate) DatePicker(currentDateTime),
        if (mode.hasTime) TimePicker(currentDateTime),
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

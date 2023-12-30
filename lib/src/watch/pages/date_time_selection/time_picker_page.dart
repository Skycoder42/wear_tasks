import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../widgets/side_button.dart';
import '../../widgets/watch_dialog.dart';

class TimePickerPage extends HookWidget {
  static const _minuteInterval = 5;

  final DateTime initialTime;

  const TimePickerPage({
    super.key,
    required this.initialTime,
  });

  @override
  Widget build(BuildContext context) {
    final pickerKey = useState(GlobalKey());
    final currentDateTime = useState(_toIntervalTime(initialTime));

    return WatchDialog<TimeOfDay>(
      horizontalSafeArea: true,
      onAccept: () => TimeOfDay.fromDateTime(currentDateTime.value),
      bottomAction: Center(
        child: SideButton(
          icon: const Icon(Icons.today_outlined),
          onPressed: () {
            currentDateTime.value = _toIntervalTime(DateTime.now());
            pickerKey.value = GlobalKey();
          },
        ),
      ),
      body: SafeArea(
        child: CupertinoDatePicker(
          key: pickerKey.value,
          mode: CupertinoDatePickerMode.time,
          use24hFormat: true,
          minuteInterval: 5,
          initialDateTime: currentDateTime.value,
          onDateTimeChanged: (value) => currentDateTime.value = value,
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<DateTime>('initialTime', initialTime));
  }

  DateTime _toIntervalTime(DateTime dateTime) => dateTime.copyWith(
        minute: (dateTime.minute / _minuteInterval).round() * _minuteInterval,
      );
}

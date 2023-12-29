import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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
    final initialIntervalDateTime = useMemoized(
      () => initialTime.copyWith(
        minute:
            (initialTime.minute / _minuteInterval).round() * _minuteInterval,
      ),
      [initialTime],
    );
    final currentDateTime = useState(initialIntervalDateTime);

    return WatchDialog<TimeOfDay>(
      horizontalSafeArea: true,
      onAccept: () => TimeOfDay.fromDateTime(currentDateTime.value),
      body: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        use24hFormat: true,
        minuteInterval: 5,
        initialDateTime: initialIntervalDateTime,
        onDateTimeChanged: (value) => currentDateTime.value = value,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<DateTime>('initialTime', initialTime));
  }
}

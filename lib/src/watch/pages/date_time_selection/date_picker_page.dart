import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../widgets/watch_dialog.dart';

class DatePickerPage extends HookWidget {
  final DateTime initialDate;

  const DatePickerPage({
    super.key,
    required this.initialDate,
  });

  @override
  Widget build(BuildContext context) {
    final currentDateTime = useState(initialDate);

    return WatchDialog<DateTime>(
      // horizontalSafeArea: true,
      onAccept: () => currentDateTime.value,
      body: CalendarDatePicker(
        initialDate: initialDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(10000),
        onDateChanged: (value) => currentDateTime.value = value,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<DateTime>('initialDate', initialDate));
  }
}

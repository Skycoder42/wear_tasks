import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class TimePicker extends HookWidget {
  static const _minuteInterval = 5;

  static DateTime toIntervalTime(DateTime dateTime) => dateTime.copyWith(
        minute: (dateTime.minute / _minuteInterval).round() * _minuteInterval,
      );

  final ValueNotifier<DateTime> dateTime;

  const TimePicker(
    this.dateTime, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final initialIntervalTime = useValueListenable(dateTime);

    final pickerKey = useState(GlobalKey());
    final currentDateTime = useState(initialIntervalTime);

    useEffect(
      () {
        if (initialIntervalTime != currentDateTime.value) {
          currentDateTime.value = initialIntervalTime;
          pickerKey.value = GlobalKey();
        }
        return null;
      },
      [pickerKey, initialIntervalTime],
    );

    return SafeArea(
      child: CupertinoDatePicker(
        key: pickerKey.value,
        mode: CupertinoDatePickerMode.time,
        use24hFormat: true,
        minuteInterval: 5,
        initialDateTime: initialIntervalTime,
        onDateTimeChanged: (value) {
          dateTime.value = currentDateTime.value = dateTime.value.copyWith(
            hour: value.hour,
            minute: value.minute,
            second: 0,
            millisecond: 0,
            microsecond: 0,
          );
        },
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<ValueNotifier<DateTime>>('dateTime', dateTime),
    );
  }
}

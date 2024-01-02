import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/extensions/core_extensions.dart';
import 'date_time_controller.dart';

class TimePicker extends HookConsumerWidget {
  final DateTime initialDateTime;

  DateTimeControllerProvider get _controllerProvider =>
      dateTimeControllerProvider(initialDateTime);

  const TimePicker(this.initialDateTime, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateTimeController = ref.watch(_controllerProvider.notifier);
    final initialTime = ref.read(_controllerProvider).time;

    final pickerKey = useState(GlobalKey());
    final currentTime = useState(initialTime);

    ref.listen(
      _controllerProvider.select((v) => v.time),
      (_, time) {
        if (time != currentTime.value) {
          currentTime.value = time;
          pickerKey.value = GlobalKey();
        }
      },
    );

    return SafeArea(
      child: CupertinoDatePicker(
        key: pickerKey.value,
        mode: CupertinoDatePickerMode.time,
        use24hFormat: true,
        minuteInterval: DateTimeController.minuteInterval,
        initialDateTime: initialTime,
        onDateTimeChanged: (value) {
          currentTime.value = value;
          dateTimeController.updateTime(value.hour, value.minute);
        },
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/extensions/core_extensions.dart';
import '../../../common/localization/localization.dart';
import '../../app/watch_theme.dart';
import '../../widgets/hooks/rotary_scroll_controller_hook.dart';
import '../../widgets/interaction_detector.dart';
import 'date_time_controller.dart';

enum TimePickerColumn {
  hour,
  minute,
}

class TimePicker extends HookConsumerWidget {
  static const itemExtend = 32.0;

  final DateTime initialDateTime;

  DateTimeControllerProvider get _controllerProvider =>
      dateTimeControllerProvider(initialDateTime);

  const TimePicker(this.initialDateTime, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateTimeController = ref.watch(_controllerProvider.notifier);
    final initialTime = ref.read(_controllerProvider).time;
    final activeColumn = useState(TimePickerColumn.hour);

    final hourController = useRotaryFixedExtentScrollController(
      ref,
      itemExtend: itemExtend,
      initialIndex: initialTime.hour,
      enabled: activeColumn.value == TimePickerColumn.hour,
    );
    final minuteController = useRotaryFixedExtentScrollController(
      ref,
      itemExtend: itemExtend,
      initialIndex: initialTime.minute ~/ DateTimeController.minuteInterval,
      enabled: activeColumn.value == TimePickerColumn.minute,
    );

    ref
      ..listen(
        _controllerProvider.select((d) => d.hour),
        (_, hourIndex) => _syncController(hourController, hourIndex, 24),
      )
      ..listen(
        _controllerProvider
            .select((d) => d.minute ~/ DateTimeController.minuteInterval),
        (_, minuteIndex) => _syncController(
          minuteController,
          minuteIndex,
          60 ~/ DateTimeController.minuteInterval,
        ),
      );

    TextStyle? styleFor(TimePickerColumn column) => column == activeColumn.value
        ? TextStyle(color: context.theme.colorScheme.primary)
        : null;

    return SafeArea(
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              height: itemExtend,
              width: 100,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: context.theme.focusColor,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Flexible(child: SizedBox()),
              Flexible(
                flex: 2,
                child: InteractionDetector(
                  onInteraction: () =>
                      activeColumn.value = TimePickerColumn.hour,
                  child: CupertinoPicker(
                    looping: true,
                    itemExtent: itemExtend,
                    selectionOverlay: null,
                    scrollController: hourController,
                    onSelectedItemChanged: dateTimeController.updateHour,
                    children: [
                      for (var hour = 0; hour < 24; ++hour)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              context.strings
                                  .time_picker_hour(DateTime(0, 0, 0, hour)),
                              style: styleFor(TimePickerColumn.hour),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 2,
                child: InteractionDetector(
                  onInteraction: () =>
                      activeColumn.value = TimePickerColumn.minute,
                  child: CupertinoPicker(
                    looping: true,
                    itemExtent: itemExtend,
                    selectionOverlay: null,
                    scrollController: minuteController,
                    onSelectedItemChanged: (minuteIndex) =>
                        dateTimeController.updateMinute(
                      minuteIndex * DateTimeController.minuteInterval,
                    ),
                    children: [
                      for (var minute = 0;
                          minute < 60;
                          minute += DateTimeController.minuteInterval)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              context.strings.time_picker_minute(
                                DateTime(0, 0, 0, 0, minute),
                              ),
                              style: styleFor(TimePickerColumn.minute),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const Flexible(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  void _syncController(
    FixedExtentScrollController controller,
    int index,
    int limit,
  ) {
    final unloopedIndex = controller.selectedItem % limit;
    if (controller.hasClients && unloopedIndex != index) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.jumpToItem(index);
      });
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<DateTime>('initialDateTime', initialDateTime));
  }
}

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

enum DatePickerColumn {
  year,
  month,
  day,
}

class DatePicker extends HookConsumerWidget {
  static const itemExtend = 32.0;

  final DateTime initialDateTime;

  DateTimeControllerProvider get _controllerProvider =>
      dateTimeControllerProvider(initialDateTime);

  const DatePicker(this.initialDateTime, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateTimeController = ref.watch(_controllerProvider.notifier);
    final initialDateTime = ref.read(_controllerProvider);
    final activeColumn = useState(DatePickerColumn.day);

    final dayController = useRotaryFixedExtentScrollController(
      ref,
      itemExtend: itemExtend,
      initialIndex: initialDateTime.day - 1,
      enabled: activeColumn.value == DatePickerColumn.day,
    );
    final monthController = useRotaryFixedExtentScrollController(
      ref,
      itemExtend: itemExtend,
      initialIndex: initialDateTime.month - 1,
      enabled: activeColumn.value == DatePickerColumn.month,
    );
    final yearController = useRotaryFixedExtentScrollController(
      ref,
      itemExtend: itemExtend,
      initialIndex: initialDateTime.year,
      enabled: activeColumn.value == DatePickerColumn.year,
    );

    ref
      ..listen(
        _controllerProvider.select((d) => d.month - 1),
        (_, monthIndex) => _syncController(monthController, monthIndex, 12),
      )
      ..listen(
        _controllerProvider.select((d) => d.year),
        (_, yearIndex) => _syncController(yearController, yearIndex, null),
      );

    TextStyle? styleFor(DatePickerColumn column) => column == activeColumn.value
        ? TextStyle(color: context.theme.colorScheme.primary)
        : null;

    return SafeArea(
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              height: itemExtend,
              width: double.infinity,
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
              Flexible(
                flex: 2,
                child: Consumer(
                  builder: (context, ref, _) {
                    final daysInMonth = ref.watch(
                      _controllerProvider.select((d) => d.daysInMonth),
                    );
                    ref.listen(
                      _controllerProvider.select((d) => d.day - 1),
                      (_, dayIndex) => _syncController(
                        dayController,
                        dayIndex,
                        daysInMonth,
                      ),
                    );

                    return InteractionDetector(
                      onInteraction: () =>
                          activeColumn.value = DatePickerColumn.day,
                      child: CupertinoPicker(
                        looping: true,
                        itemExtent: itemExtend,
                        selectionOverlay: null,
                        scrollController: dayController,
                        onSelectedItemChanged: (dayIndex) =>
                            dateTimeController.updateDay(dayIndex + 1),
                        children: [
                          for (var day = 1; day <= daysInMonth; ++day)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  context.strings
                                      .date_picker_day(DateTime(0, 1, day)),
                                  style: styleFor(DatePickerColumn.day),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Flexible(
                flex: 3,
                child: InteractionDetector(
                  onInteraction: () =>
                      activeColumn.value = DatePickerColumn.month,
                  child: CupertinoPicker(
                    looping: true,
                    itemExtent: itemExtend,
                    selectionOverlay: null,
                    scrollController: monthController,
                    onSelectedItemChanged: (monthIndex) =>
                        dateTimeController.updateMonth(monthIndex + 1),
                    children: [
                      for (var month = 1; month <= 12; ++month)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              context.strings
                                  .date_picker_month(DateTime(0, month)),
                              style: styleFor(DatePickerColumn.month),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 3,
                child: InteractionDetector(
                  onInteraction: () =>
                      activeColumn.value = DatePickerColumn.year,
                  child: CupertinoPicker.builder(
                    itemExtent: itemExtend,
                    selectionOverlay: null,
                    scrollController: yearController,
                    onSelectedItemChanged: dateTimeController.updateYear,
                    itemBuilder: (context, index) => Row(
                      children: [
                        Text(
                          context.strings.date_picker_year(DateTime(index)),
                          style: styleFor(DatePickerColumn.year),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _syncController(
    FixedExtentScrollController controller,
    int index,
    int? limit,
  ) {
    final unloopedIndex = limit != null
        ? controller.selectedItem % limit
        : controller.selectedItem;
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/extensions/core_extensions.dart';
import '../../../common/localization/localization.dart';
import '../../widgets/hooks/rotary_scroll_controller_hook.dart';
import 'date_time_controller.dart';

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

    final dayController = useRotaryFixedExtentScrollController(
      ref,
      itemExtend: itemExtend,
      initialIndex: initialDateTime.day - 1,
    );
    final monthController = useRotaryFixedExtentScrollController(
      ref,
      itemExtend: itemExtend,
      initialIndex: initialDateTime.month - 1,
    );
    final yearController = useRotaryFixedExtentScrollController(
      ref,
      itemExtend: itemExtend,
      initialIndex: initialDateTime.year,
    );

    ref
      ..listen(
        _controllerProvider.select((d) => d.day - 1),
        (_, dayIndex) => _syncController(dayController, dayIndex),
      )
      ..listen(
        _controllerProvider.select((d) => d.month - 1),
        (_, monthIndex) => _syncController(monthController, monthIndex),
      )
      ..listen(
        _controllerProvider.select((d) => d.year),
        (_, yearIndex) => _syncController(yearController, yearIndex),
      );

    return SafeArea(
      child: Stack(
        children: [
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
                    return CupertinoPicker(
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
                              ),
                            ],
                          ),
                      ],
                    );
                  },
                ),
              ),
              Flexible(
                flex: 3,
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
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Flexible(
                flex: 3,
                child: CupertinoPicker.builder(
                  itemExtent: itemExtend,
                  selectionOverlay: null,
                  scrollController: yearController,
                  onSelectedItemChanged: dateTimeController.updateYear,
                  itemBuilder: (context, index) => Row(
                    children: [
                      Text(
                        context.strings.date_picker_year(DateTime(index)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Center(
            child: SizedBox(
              height: itemExtend,
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: CupertinoDynamicColor.resolve(
                    CupertinoColors.tertiarySystemFill,
                    context,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _syncController(
    FixedExtentScrollController controller,
    int index,
  ) {
    if (controller.hasClients && controller.selectedItem != index) {
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

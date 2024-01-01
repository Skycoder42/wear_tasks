import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../common/localization/localization.dart';
import '../../widgets/hooks/fixed_extent_scroll_controller_hook.dart';

class DatePicker extends HookWidget {
  final ValueNotifier<DateTime> dateTime;

  const DatePicker(
    this.dateTime, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final currentDateTime = useValueListenable(dateTime);

    final dayController = useFixedExtentScrollController(
      initialIndex: currentDateTime.day - 1,
    );
    final monthController = useFixedExtentScrollController(
      initialIndex: currentDateTime.month - 1,
    );
    final yearController = useFixedExtentScrollController(
      initialIndex: currentDateTime.year,
    );

    useEffect(
      () {
        _syncController(dayController, currentDateTime.day - 1);
        _syncController(monthController, currentDateTime.month - 1);
        _syncController(yearController, currentDateTime.year);
        return null;
      },
      [currentDateTime, dayController, monthController, yearController],
    );

    final updateDateTime = useCallback(
      // ignore: avoid_types_on_closure_parameters
      ({int? day, int? month, int? year}) {
        final updatedMonthYear = dateTime.value.copyWith(
          year: year,
          month: month,
          day: 1,
        );
        final updateDate = updatedMonthYear.copyWith(
          day: min(
            updatedMonthYear.daysInMonth,
            day ?? dateTime.value.day,
          ),
        );
        dateTime.value = updateDate;
      },
      [dateTime],
    );

    return SafeArea(
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 2,
                child: CupertinoPicker(
                  looping: true,
                  itemExtent: 32,
                  selectionOverlay: null,
                  scrollController: dayController,
                  onSelectedItemChanged: (day) => updateDateTime(day: day + 1),
                  children: [
                    for (var day = 1; day <= currentDateTime.daysInMonth; ++day)
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
                ),
              ),
              Flexible(
                flex: 3,
                child: CupertinoPicker(
                  looping: true,
                  itemExtent: 32,
                  selectionOverlay: null,
                  scrollController: monthController,
                  onSelectedItemChanged: (month) =>
                      updateDateTime(month: month + 1),
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
                child: CupertinoPicker(
                  itemExtent: 32,
                  selectionOverlay: null,
                  scrollController: yearController,
                  onSelectedItemChanged: (year) => updateDateTime(year: year),
                  children: [
                    for (var year = 0; year < 10000; ++year)
                      Row(
                        children: [
                          Text(
                            context.strings.date_picker_year(DateTime(year)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          Center(
            child: SizedBox(
              height: 32,
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
    properties.add(
      DiagnosticsProperty<ValueNotifier<DateTime>>('dateTime', dateTime),
    );
  }
}

extension on DateTime {
  int get daysInMonth => DateTime(year, month + 1, 0).day;
}

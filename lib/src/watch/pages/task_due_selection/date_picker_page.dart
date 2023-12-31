import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../common/localization/localization.dart';
import '../../widgets/hooks/fixed_extent_scroll_controller_hook.dart';
import '../../widgets/side_button.dart';
import '../../widgets/watch_dialog.dart';

class DatePickerPage extends HookWidget {
  final DateTime initialDate;

  const DatePickerPage({
    super.key,
    required this.initialDate,
  });

  @override
  Widget build(BuildContext context) {
    final dayController = useFixedExtentScrollController(
      initialIndex: initialDate.day - 1,
    );
    final monthController = useFixedExtentScrollController(
      initialIndex: initialDate.month - 1,
    );
    final yearController = useFixedExtentScrollController(
      initialIndex: initialDate.year,
    );

    final currentDateTime = useState(initialDate);
    final updateDateTime = useCallback(
      // ignore: avoid_types_on_closure_parameters
      ({int? day, int? month, int? year}) {
        final updatedMonthYear = DateTime(
          year ?? currentDateTime.value.year,
          month ?? currentDateTime.value.month,
        );
        currentDateTime.value = updatedMonthYear.copyWith(
          day: min(
            updatedMonthYear.daysInMonth,
            day ?? currentDateTime.value.day,
          ),
        );

        if (day == null) {
          dayController.jumpToItem(currentDateTime.value.day - 1);
        }
        if (month == null) {
          monthController.jumpToItem(currentDateTime.value.month - 1);
        }
        if (year == null) {
          yearController.jumpToItem(currentDateTime.value.year);
        }
      },
      [currentDateTime, dayController, monthController, yearController],
    );

    return WatchDialog<DateTime>(
      horizontalSafeArea: true,
      bottomAction: Center(
        child: SideButton(
          icon: const Icon(Icons.today),
          onPressed: () {
            currentDateTime.value = DateTime.now();
            updateDateTime();
          },
        ),
      ),
      onAccept: () => currentDateTime.value,
      body: SafeArea(
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
                    onSelectedItemChanged: (day) =>
                        updateDateTime(day: day + 1),
                    children: [
                      for (var day = 1;
                          day <= currentDateTime.value.daysInMonth;
                          ++day)
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
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<DateTime>('initialDate', initialDate));
  }
}

extension on DateTime {
  int get daysInMonth => DateTime(year, month + 1, 0).day;
}

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../app/watch_theme.dart';
import '../../widgets/hooks/fixed_extent_scroll_controller_hook.dart';
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
      [currentDateTime],
    );

    return WatchDialog<DateTime>(
      horizontalSafeArea: true,
      onAccept: () => currentDateTime.value,
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              height: 32,
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: context.theme.colorScheme.surface,
                ),
              ),
            ),
          ),
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
                    for (var i = 1; i <= currentDateTime.value.daysInMonth; ++i)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('$i.'),
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
                    for (final i in [
                      'Jan',
                      'Feb',
                      'Mär',
                      'Apr',
                      'Mai',
                      'Jun',
                      'Jul',
                      'Aug',
                      'Sep',
                      'Okt',
                      'Nov',
                      'Dez',
                    ])
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(i),
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
                    for (var i = 0; i < 10000; ++i)
                      Row(
                        children: [
                          Text('$i'),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
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

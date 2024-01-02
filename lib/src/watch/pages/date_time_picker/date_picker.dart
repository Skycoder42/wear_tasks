import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/extensions/core_extensions.dart';
import '../../../common/localization/localization.dart';
import '../../widgets/hooks/fixed_extent_scroll_controller_hook.dart';
import 'date_time_controller.dart';

class DatePicker extends HookConsumerWidget {
  const DatePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateTimeController = ref.watch(dateTimeControllerProvider.notifier);
    final initialDateTime = ref.read(dateTimeControllerProvider);

    final dayController = useFixedExtentScrollController(
      initialIndex: initialDateTime.day - 1,
    );
    final monthController = useFixedExtentScrollController(
      initialIndex: initialDateTime.month - 1,
    );
    final yearController = useFixedExtentScrollController(
      initialIndex: initialDateTime.year,
    );

    ref
      ..listen(
        dateTimeControllerProvider.select((d) => d.day - 1),
        (_, dayIndex) => _syncController(dayController, dayIndex),
      )
      ..listen(
        dateTimeControllerProvider.select((d) => d.month - 1),
        (_, monthIndex) => _syncController(monthController, monthIndex),
      )
      ..listen(
        dateTimeControllerProvider.select((d) => d.year),
        (_, yearIndex) => _syncController(yearController, yearIndex),
      );

    // TODO this is sluggish!
    final daysInMonth = ref.watch(
      dateTimeControllerProvider.select((d) => d.daysInMonth),
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
                ),
              ),
              Flexible(
                flex: 3,
                child: CupertinoPicker(
                  looping: true,
                  itemExtent: 32,
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
                child: CupertinoPicker(
                  itemExtent: 32,
                  selectionOverlay: null,
                  scrollController: yearController,
                  onSelectedItemChanged: dateTimeController.updateYear,
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
}

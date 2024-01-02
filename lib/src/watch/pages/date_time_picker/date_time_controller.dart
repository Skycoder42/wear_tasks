import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/extensions/core_extensions.dart';

part 'date_time_controller.g.dart';

@riverpod
class DateTimeController extends _$DateTimeController {
  static const minuteInterval = 5;

  @override
  DateTime build() => _toIntervalTime(DateTime.now());

  void initialize(DateTime dateTime) => state = _toIntervalTime(dateTime);

  DateTime updateYear(int year) => _updateDate(year: year);

  DateTime updateMonth(int month) => _updateDate(month: month);

  DateTime updateDay(int day) => _updateDate(day: day);

  DateTime updateTime(int hour, int minute) =>
      state = state.copyWith(hour: hour, minute: minute);

  void resetDate() {
    final now = _toIntervalTime(DateTime.now());
    state = state.copyWith(
      year: now.year,
      month: now.month,
      day: now.day,
    );
  }

  void resetTime() {
    final now = _toIntervalTime(DateTime.now());
    state = state.copyWith(
      hour: now.hour,
      minute: now.minute,
    );
  }

  DateTime _updateDate({int? day, int? month, int? year}) {
    final updatedMonthYear = state.copyWith(
      year: year,
      month: month,
      day: 1,
    );
    final updateDate = updatedMonthYear.copyWith(
      day: min(
        updatedMonthYear.daysInMonth,
        day ?? state.day,
      ),
    );
    return state = updateDate;
  }

  static DateTime _toIntervalTime(DateTime dateTime) => dateTime.copyWith(
        minute: (dateTime.minute / minuteInterval).round() * minuteInterval,
        second: 0,
        millisecond: 0,
        microsecond: 0,
      );
}

import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'date_time_controller.g.dart';

@riverpod
class DateTimeController extends _$DateTimeController {
  static const _minuteInterval = 5;

  @override
  DateTime build() => _toIntervalTime(DateTime.now());

  void updateYear(int year) => _updateDate(year: year);

  void updateMonth(int month) => _updateDate(month: month);

  void updateDay(int day) => _updateDate(day: day);

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

  void _updateDate({int? day, int? month, int? year}) {
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
    state = updateDate;
  }

  static DateTime _toIntervalTime(DateTime dateTime) => dateTime.copyWith(
        minute: (dateTime.minute / _minuteInterval).round() * _minuteInterval,
        second: 0,
        millisecond: 0,
        microsecond: 0,
      );
}

// TODO move
extension on DateTime {
  int get daysInMonth => DateTime(year, month + 1, 0).day;
}

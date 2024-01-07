import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/extensions/core_extensions.dart';

part 'relative_date.freezed.dart';

/*
years
  - months
    - weeks
      - days
        - hours
          - minutes
          - minute
        - hour
          - minute
      - weekDay
        - hour
          - minute
    - monthDay
      - hour
        - minute
  - month
    - monthDay
      - hour
        - minute
  - week
    - weekDay
      - hour
        - minute
*/

abstract interface class RelativeDate {
  DateTime apply(DateTime dateTime);
}

@freezed
sealed class RelativeHours with _$RelativeHours implements RelativeDate {
  const factory RelativeHours(int hours) = _RelativeHours;

  const factory RelativeHours.minutes(int hours, int minutes) =
      _RelativeHoursMinutes;

  @Assert('minute >= 0 && minute < 60')
  const factory RelativeHours.minute(int hours, int minute) =
      _RelativeHoursMinute;

  const RelativeHours._();

  @override
  DateTime apply(DateTime dateTime) => switch (this) {
        _RelativeHours(hours: final hours) =>
          dateTime.add(Duration(hours: hours)),
        _RelativeHoursMinutes(hours: final hours, minutes: final minutes) =>
          dateTime.add(Duration(hours: hours, minutes: minutes)),
        _RelativeHoursMinute(hours: final hours, minute: final minute) =>
          dateTime.add(Duration(hours: hours)).copyWith(minute: minute),
      };
}

@freezed
sealed class RelativeDays with _$RelativeDays implements RelativeDate {
  const factory RelativeDays(int days) = _RelativeDays;

  const factory RelativeDays.hours(int days, RelativeHours hours) =
      _RelativeDaysHours;

  @Assert('hour >= 0 && hour < 60')
  @Assert('minute >= 0 && minute < 60')
  const factory RelativeDays.hour(
    int days,
    int hour, [
    @Default(0) int minute,
  ]) = _RelativeDaysHour;

  const RelativeDays._();

  @override
  DateTime apply(DateTime dateTime) => switch (this) {
        _RelativeDays(days: final days) => dateTime.add(Duration(days: days)),
        _RelativeDaysHours(days: final days, hours: final hours) =>
          hours.apply(dateTime.add(Duration(days: days))),
        _RelativeDaysHour(
          days: final days,
          hour: final hour,
          minute: final minute,
        ) =>
          dateTime
              .add(Duration(days: days))
              .copyWith(hour: hour, minute: minute),
      };
}

@freezed
sealed class RelativeWeeks with _$RelativeWeeks implements RelativeDate {
  const factory RelativeWeeks(int weeks) = _RelativeWeeks;

  const factory RelativeWeeks.days(int weeks, RelativeDays days) =
      _RelativeWeeksDays;

  @Assert('weekDay >= 1 && weekDay <= 7')
  @Assert('hour >= 0 && hour < 60')
  @Assert('minute >= 0 && minute < 60')
  const factory RelativeWeeks.weekDay(
    int weeks,
    int weekDay, [
    @Default(0) int hour,
    @Default(0) int minute,
  ]) = _RelativeWeeksDay;

  const RelativeWeeks._();

  @override
  DateTime apply(DateTime dateTime) => switch (this) {
        _RelativeWeeks(weeks: final weeks) =>
          dateTime.add(Duration(days: DateTime.daysPerWeek * weeks)),
        _RelativeWeeksDays(weeks: final weeks, days: final days) => days
            .apply(dateTime.add(Duration(days: DateTime.daysPerWeek * weeks))),
        _RelativeWeeksDay(
          weeks: final weeks,
          weekDay: final weekDay,
          hour: final hour,
          minute: final minute,
        ) =>
          dateTime
              .add(Duration(days: DateTime.daysPerWeek * weeks))
              .add(Duration(days: weekDay - dateTime.weekday))
              .copyWith(hour: hour, minute: minute),
      };
}

@freezed
sealed class RelativeMonths with _$RelativeMonths implements RelativeDate {
  const factory RelativeMonths(int months) = _RelativeMonths;

  const factory RelativeMonths.weeks(int months, RelativeWeeks weeks) =
      _RelativeMonthsWeeks;

  @Assert('monthDay >= 1 && monthDay <= 31')
  @Assert('hour >= 0 && hour < 60')
  @Assert('minute >= 0 && minute < 60')
  const factory RelativeMonths.monthDay(
    int months,
    int monthDay, [
    @Default(0) int hour,
    @Default(0) int minute,
  ]) = _RelativeMonthsDay;

  const RelativeMonths._();

  @override
  DateTime apply(DateTime dateTime) => switch (this) {
        _RelativeMonths(months: final months) => dateTime.addMonths(months),
        _RelativeMonthsWeeks(months: final months, weeks: final weeks) =>
          weeks.apply(dateTime.addMonths(months)),
        _RelativeMonthsDay(
          months: final months,
          monthDay: final monthDay,
          hour: final hour,
          minute: final minute,
        ) =>
          _applyMdHM(dateTime.addMonths(months), monthDay, hour, minute),
      };

  static DateTime _applyMdHM(DateTime dt, int md, int h, int m) => dt.copyWith(
        day: min(md, dt.daysInMonth),
        hour: h,
        minute: m,
      );
}

// TODO here

@freezed
sealed class RelativeYears with _$RelativeYears implements RelativeDate {
  const factory RelativeYears(int years) = _RelativeYears;

  const factory RelativeYears.months(int years, RelativeMonths months) =
      _RelativeYearsMonths;

  @Assert('month >= 1 && month <= 12')
  @Assert('monthDay >= 1 && monthDay <= 31')
  @Assert('hour >= 0 && hour < 60')
  @Assert('minute >= 0 && minute < 60')
  const factory RelativeYears.month(
    int years,
    int month, [
    @Default(1) int monthDay,
    @Default(0) int hour,
    @Default(0) int minute,
  ]) = _RelativeYearsMonth;

  @Assert('week >= 1 && week <= 52')
  @Assert('weekDay >= 1 && weekDay <= 7')
  @Assert('hour >= 0 && hour < 60')
  @Assert('minute >= 0 && minute < 60')
  const factory RelativeYears.week(
    int years,
    int week, [
    @Default(1) int weekDay,
    @Default(0) int hour,
    @Default(0) int minute,
  ]) = _RelativeYearsWeek;

  const RelativeYears._();

  @override
  DateTime apply(DateTime dateTime) => switch (this) {
        _RelativeYears(years: final years) => dateTime.addYears(years),
        _RelativeYearsMonths(years: final years, months: final months) =>
          months.apply(dateTime.addYears(years)),
        _RelativeYearsMonth(
          years: final years,
          month: final month,
          monthDay: final monthDay,
          hour: final hour,
          minute: final minute,
        ) =>
          RelativeMonths._applyMdHM(
            dateTime.addYears(years).copyWith(month: month),
            monthDay,
            hour,
            minute,
          ),
        _RelativeYearsWeek() =>
          throw UnimplementedError('TODO not implemented yet'),
      };
}

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
  @Assert('minute == null || (minute >= 0 && minute < 60)')
  const factory RelativeDays.hour(
    int days,
    int hour, [
    int? minute,
  ]) = _RelativeDaysHour;

  const RelativeDays._();

  @override
  DateTime apply(DateTime dateTime) => switch (this) {
        _RelativeDays(days: final days) => dateTime.add(Duration(days: days)),
        _RelativeDaysHours(days: final days, hours: final hours) =>
          hours.apply(dateTime.add(Duration(days: days))),
        final _RelativeDaysHour rdh => dateTime
            .add(Duration(days: rdh.days))
            .copyWith(hour: rdh.hour, minute: rdh.minute),
      };
}

@freezed
sealed class RelativeWeeks with _$RelativeWeeks implements RelativeDate {
  const factory RelativeWeeks(int weeks) = _RelativeWeeks;

  const factory RelativeWeeks.days(int weeks, RelativeDays days) =
      _RelativeWeeksDays;

  @Assert('weekDay >= DateTime.monday && weekDay <= DateTime.sunday')
  @Assert('hour == null || (hour >= 0 && hour < 60)')
  @Assert('minute == null || (minute >= 0 && minute < 60)')
  const factory RelativeWeeks.weekDay(
    int weeks,
    int weekDay, [
    int? hour,
    int? minute,
  ]) = _RelativeWeeksDay;

  const RelativeWeeks._();

  @override
  DateTime apply(DateTime dateTime) => switch (this) {
        _RelativeWeeks(weeks: final weeks) =>
          dateTime.add(Duration(days: DateTime.daysPerWeek * weeks)),
        _RelativeWeeksDays(weeks: final weeks, days: final days) => days
            .apply(dateTime.add(Duration(days: DateTime.daysPerWeek * weeks))),
        final _RelativeWeeksDay rwd => _applyWdHM(
            dateTime.add(Duration(days: DateTime.daysPerWeek * rwd.weeks)),
            rwd.weekDay,
            rwd.hour,
            rwd.minute,
          ),
      };

  static DateTime _applyWdHM(
    DateTime dateTime,
    int? weekDay,
    int? hour,
    int? minute,
  ) =>
      dateTime
          .add(
            weekDay != null
                ? Duration(days: weekDay - dateTime.weekday)
                : Duration.zero,
          )
          .copyWith(hour: hour, minute: minute);
}

@freezed
sealed class RelativeMonths with _$RelativeMonths implements RelativeDate {
  const factory RelativeMonths(int months) = _RelativeMonths;

  const factory RelativeMonths.weeks(int months, RelativeWeeks weeks) =
      _RelativeMonthsWeeks;

  @Assert('monthDay >= 1 && monthDay <= 31')
  @Assert('hour == null || (hour >= 0 && hour < 60)')
  @Assert('minute == null || (minute >= 0 && minute < 60)')
  const factory RelativeMonths.monthDay(
    int months,
    int monthDay, [
    int? hour,
    int? minute,
  ]) = _RelativeMonthsDay;

  const RelativeMonths._();

  @override
  DateTime apply(DateTime dateTime) => switch (this) {
        _RelativeMonths(months: final months) => dateTime.addMonths(months),
        _RelativeMonthsWeeks(months: final months, weeks: final weeks) =>
          weeks.apply(dateTime.addMonths(months)),
        final _RelativeMonthsDay rmd => _applyMdHM(
            dateTime.addMonths(rmd.months),
            rmd.monthDay,
            rmd.hour,
            rmd.minute,
          ),
      };

  static DateTime _applyMdHM(
    DateTime dateTime,
    int? monthDay,
    int? hour,
    int? minute,
  ) =>
      dateTime.copyWith(
        day: monthDay != null ? min(monthDay, dateTime.daysInMonth) : null,
        hour: hour,
        minute: minute,
      );
}

@freezed
sealed class RelativeYears with _$RelativeYears implements RelativeDate {
  const factory RelativeYears(int years) = _RelativeYears;

  const factory RelativeYears.months(int years, RelativeMonths months) =
      _RelativeYearsMonths;

  @Assert('month >= DateTime.january && month <= DateTime.december')
  @Assert('monthDay == null || (monthDay >= 1 && monthDay <= 31)')
  @Assert('hour == null || (hour >= 0 && hour < 60)')
  @Assert('minute == null || (minute >= 0 && minute < 60)')
  const factory RelativeYears.month(
    int years,
    int month, [
    int? monthDay,
    int? hour,
    int? minute,
  ]) = _RelativeYearsMonth;

  @Assert('week >= 1 && week <= 52')
  @Assert(
    'weekDay == null || '
    '(weekDay >= DateTime.monday && weekDay <= DateTime.sunday)',
  )
  @Assert('hour == null || (hour >= 0 && hour < 60)')
  @Assert('minute == null || (minute >= 0 && minute < 60)')
  const factory RelativeYears.week(
    int years,
    int week, [
    int? weekDay,
    int? hour,
    int? minute,
  ]) = _RelativeYearsWeek;

  const RelativeYears._();

  @override
  DateTime apply(DateTime dateTime) => switch (this) {
        _RelativeYears(years: final years) => dateTime.addYears(years),
        _RelativeYearsMonths(years: final years, months: final months) =>
          months.apply(dateTime.addYears(years)),
        final _RelativeYearsMonth rym => RelativeMonths._applyMdHM(
            dateTime.addYears(rym.years).copyWith(month: rym.month),
            rym.monthDay,
            rym.hour,
            rym.minute,
          ),
        final _RelativeYearsWeek ryw => _applyWWdHM(
            dateTime.addYears(ryw.years),
            ryw.week,
            ryw.weekDay,
            ryw.hour,
            ryw.minute,
          ),
      };

  static DateTime _applyWWdHM(
    DateTime dateTime,
    int week,
    int? weekDay,
    int? hour,
    int? minute,
  ) {
    final firstWeekDay = DateTime(dateTime.year).weekday;
    final firstWeekDate = switch (firstWeekDay) {
      DateTime.monday => dateTime,
      DateTime.tuesday ||
      DateTime.wednesday ||
      DateTime.thursday =>
        dateTime.subtract(Duration(days: firstWeekDay - 1)),
      DateTime.friday ||
      DateTime.saturday ||
      DateTime.sunday =>
        dateTime.add(Duration(days: 8 - firstWeekDay)),
      _ => dateTime, // impossible case
    };
    assert(firstWeekDate.weekday == DateTime.monday);

    return RelativeWeeks._applyWdHM(
      firstWeekDate.add(Duration(days: DateTime.daysPerWeek * (week - 1))),
      weekDay,
      hour,
      minute,
    );
  }
}

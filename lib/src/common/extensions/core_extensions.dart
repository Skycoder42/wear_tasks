import 'package:flutter/material.dart';

extension DateTimeX on DateTime {
  int get daysInMonth => DateTime(year, month + 1, 0).day;

  DateTime addMonths(int months) => copyWith(month: month + months);

  DateTime addYears(int years) => copyWith(year: year + years);

  DateTime get date =>
      isUtc ? DateTime.utc(year, month, day) : DateTime(year, month, day);

  DateTime get time => isUtc
      ? DateTime.utc(0, 1, 1, hour, minute, second, millisecond, microsecond)
      : DateTime(0, 1, 1, hour, minute, second, millisecond, microsecond);
}

extension TimeOfDayX on TimeOfDay {
  DateTime toDateTime([DateTime? date]) => DateTime(
        date?.year ?? 0,
        date?.month ?? 1,
        date?.day ?? 1,
        hour,
        minute,
      );
}

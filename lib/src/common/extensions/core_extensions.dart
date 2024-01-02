extension DateTimeX on DateTime {
  int get daysInMonth => DateTime(year, month + 1, 0).day;

  DateTime get date =>
      isUtc ? DateTime.utc(year, month, day) : DateTime(year, month, day);

  DateTime get time => isUtc
      ? DateTime.utc(0, 1, 1, hour, minute, second, millisecond, microsecond)
      : DateTime(0, 1, 1, hour, minute, second, millisecond, microsecond);
}

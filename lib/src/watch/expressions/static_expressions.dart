import '../../common/localization/localization.dart';
import 'expression.dart';
import 'relative_date.dart';

const staticExpressions = [
  In1Hour(),
  ThisEvening(),
  Tomorrow(),
  NextWeek(),
  NextMonth(),
];

final class In1Hour extends Expression {
  const In1Hour();

  @override
  String description(AppLocalizations strings) => strings.expression_in_1_hour;

  @override
  bool get applyDefaultTime => false;

  @override
  RelativeDate get relativeDate => const RelativeHours(1);
}

final class ThisEvening extends Expression {
  const ThisEvening();

  @override
  String description(AppLocalizations strings) =>
      strings.expression_this_evening;

  @override
  bool get applyDefaultTime => false;

  @override
  RelativeDate get relativeDate => const RelativeDays.hour(0, 18, 0);
}

final class Tomorrow extends Expression {
  const Tomorrow();

  @override
  String description(AppLocalizations strings) => strings.expression_tomorrow;

  @override
  bool get applyDefaultTime => true;

  @override
  RelativeDate get relativeDate => const RelativeDays(1);
}

final class NextWeek extends Expression {
  const NextWeek();

  @override
  String description(AppLocalizations strings) => strings.expression_next_week;

  @override
  bool get applyDefaultTime => true;

  @override
  RelativeDate get relativeDate =>
      const RelativeWeeks.weekDay(1, DateTime.monday);
}

final class NextMonth extends Expression {
  const NextMonth();

  @override
  String description(AppLocalizations strings) => strings.expression_next_month;

  @override
  bool get applyDefaultTime => true;

  @override
  RelativeDate get relativeDate => const RelativeMonths.monthDay(1, 1);
}

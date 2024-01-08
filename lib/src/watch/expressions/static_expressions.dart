import '../../common/localization/localization.dart';
import 'expression.dart';
import 'relative_date.dart';

final class Tomorrow extends Expression {
  @override
  String description(AppLocalizations strings) => strings.expression_tomorrow;

  @override
  RelativeDate get relativeDate => const RelativeDays(1);
}

final class NextWeek extends Expression {
  @override
  String description(AppLocalizations strings) => strings.expression_next_week;

  @override
  RelativeDate get relativeDate =>
      const RelativeWeeks.weekDay(1, DateTime.monday);
}

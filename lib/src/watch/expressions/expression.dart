import '../../common/localization/localization.dart';
import '../models/task_recurrence.dart';
import 'relative_date.dart';

abstract base class Expression {
  String description(AppLocalizations strings);

  RelativeDate get relativeDate;

  TaskRecurrence? get recurrence => null;
}

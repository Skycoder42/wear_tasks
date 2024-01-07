import '../models/task_recurrence.dart';
import 'relative_date.dart';

abstract class Expression {
  String get description;

  RelativeDate get relativeDate;

  TaskRecurrence? get recurrence;
}

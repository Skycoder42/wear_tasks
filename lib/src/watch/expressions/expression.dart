import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../common/extensions/core_extensions.dart';
import '../../common/localization/localization.dart';
import '../models/task_recurrence.dart';
import 'relative_date.dart';

abstract base class Expression {
  const Expression();

  String description(AppLocalizations strings);

  RelativeDate get relativeDate;

  bool get applyDefaultTime;

  TaskRecurrence? get recurrence => null;

  @nonVirtual
  DateTime apply(DateTime dateTime, TimeOfDay defaultTime) {
    final newDateTime = relativeDate.apply(dateTime);
    return applyDefaultTime ? defaultTime.toDateTime(newDateTime) : newDateTime;
  }
}

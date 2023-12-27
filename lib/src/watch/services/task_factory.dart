import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/localization/localization.dart';
import '../../common/providers/package_info_provider.dart';
import '../ical/ical_component.dart';
import '../models/task.dart';

part 'task_factory.g.dart';

// coverage:ignore-start
@riverpod
Future<TaskFactory> taskFactory(TaskFactoryRef ref) async => TaskFactory(
      await ref.watch(packageInfoProvider.future),
      ref.watch(appLocalizationsProvider),
    );
// coverage:ignore-end

class TaskFactory {
  final PackageInfo _packageInfo;
  final AppLocalizations _strings;

  TaskFactory(this._packageInfo, this._strings);

  ICalendar createTask(Task task) {
    final vtodo = ICalBlock('VTODO')
      ..add(ICalProperty('UID', task.uid))
      ..add(ICalProperty('DTSTAMP', task.createdAt.toICalString()))
      ..add(ICalProperty('CREATED', task.createdAt.toICalString()))
      ..add(ICalProperty('LAST-MODIFIED', task.createdAt.toICalString()))
      ..add(ICalProperty('SUMMARY', task.summary))
      ..add(ICalProperty('STATUS', task.status.value));
    if (task.priority case TaskPriority(value: final int prio)) {
      vtodo.add(ICalProperty('PRIORITY', prio.toString()));
    }
    if (task.description case final String desc) {
      vtodo.add(ICalProperty('DESCRIPTION', desc));
    }
    if (task.dueDate case final DateTime dueDate) {
      vtodo
        ..add(ICalProperty('DUE', dueDate.toICalString()))
        ..add(defaultAlarm);
    }

    final calendar = ICalBlock('VCALENDAR')
      ..add(ICalProperty('VERSION', '2.0'))
      ..add(ICalProperty('PRODID', _prodId))
      ..add(vtodo);

    return ICalendar([calendar]);
  }

  String get _prodId => '+//IDN skycoder42.de//'
      '${_packageInfo.appName} ${_packageInfo.version}//'
      '${_strings.localeName.toUpperCase()}';

  ICalBlock get defaultAlarm => ICalBlock('VALARM')
    ..add(
      ICalProperty(
        'TRIGGER',
        parameters: [ICalParameter('RELATED', 'END')],
        'PT0S',
      ),
    )
    ..add(ICalProperty('ACTION', 'DISPLAY'))
    ..add(
      ICalProperty(
        'DESCRIPTION',
        _strings.task_factory_default_alarm_description(_packageInfo.appName),
      ),
    );
}

extension on DateTime {
  String toICalString() {
    if (!isUtc) {
      return toUtc().toICalString();
    }

    final buffer = StringBuffer()
      ..write(year.toString().padLeft(4, '0'))
      ..write(month.toString().padLeft(2, '0'))
      ..write(day.toString().padLeft(2, '0'))
      ..write('T')
      ..write(hour.toString().padLeft(2, '0'))
      ..write(minute.toString().padLeft(2, '0'))
      ..write(second.toString().padLeft(2, '0'))
      ..write('Z');
    return buffer.toString();
  }
}

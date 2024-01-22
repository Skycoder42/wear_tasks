import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

typedef ParseDataCallback<T extends Object> = T Function(Map<String, dynamic>);

abstract base class WorkmanagerTask<T extends Object> {
  final ParseDataCallback<T> _fromData;

  const WorkmanagerTask(this._fromData);

  const WorkmanagerTask.noData() : _fromData = _noop;

  Future<bool> call(Ref ref, Map<String, dynamic>? data) async {
    if (_fromData == _noop) {
      return await execute(ref, null);
    } else if (data == null) {
      return await execute(ref, null);
    } else {
      return await execute(ref, _fromData(data));
    }
  }

  @protected
  FutureOr<bool> execute(Ref ref, T? data);

  static Never _noop(Map<String, dynamic> _) =>
      throw StateError('Unreachable code reached');
}

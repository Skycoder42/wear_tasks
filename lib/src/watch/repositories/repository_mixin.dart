import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';

import '../../common/extensions/etebase_extensions.dart';

mixin RepositoryMixin {
  @visibleForOverriding
  Logger get logger;

  @protected
  bool handleNetworkError(
    Object error,
    StackTrace stackTrace, [
    String? extra,
  ]) {
    if (error case EtebaseException(code: final code)
        when code.isNetworkError) {
      final msgBuilder = StringBuffer(
        'Etebase request failed due to connectivity errors',
      );
      if (extra != null) {
        msgBuilder
          ..write(' (')
          ..write(extra)
          ..write(')');
      }
      logger.warning(msgBuilder, error, stackTrace);
      return true;
    }

    return false;
  }
}

import 'package:etebase_flutter/etebase_flutter.dart';

extension EtebaseErrorCodeX on EtebaseErrorCode {
  bool get isNetworkError => switch (this) {
        EtebaseErrorCode.connection ||
        EtebaseErrorCode.temporaryServerError ||
        EtebaseErrorCode.serverError ||
        EtebaseErrorCode.http =>
          true,
        _ => false,
      };
}

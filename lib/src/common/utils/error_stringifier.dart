import 'package:etebase_flutter/etebase_flutter.dart';

abstract base class ErrorStringifier {
  ErrorStringifier._();

  static String stringify(Object error) => switch (error) {
        EtebaseException(code: final code) => code.name,
        _ => switch (error.toString().split(':')) {
            [final name, ...] => name,
            _ => error.runtimeType.toString(),
          },
      };
}

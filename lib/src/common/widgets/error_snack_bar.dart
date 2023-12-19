import 'package:flutter/material.dart';

import '../../watch/app/watch_theme.dart';

class ErrorSnackBar extends SnackBar {
  ErrorSnackBar({
    super.key,
    required BuildContext context,
    required Widget content,
  }) : super(
          backgroundColor: context.theme.colorScheme.error,
          content: DefaultTextStyle(
            style: TextStyle(color: context.theme.colorScheme.onError),
            textAlign: TextAlign.center,
            child: content,
          ),
        );
}

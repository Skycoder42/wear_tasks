import 'package:flutter/material.dart';

import '../../watch/app/watch_theme.dart';

class SuccessSnackBar extends SnackBar {
  SuccessSnackBar({
    super.key,
    required BuildContext context,
    required Widget content,
  }) : super(
          backgroundColor: context.theme.colorScheme.primary,
          content: DefaultTextStyle(
            style: TextStyle(color: context.theme.colorScheme.onPrimary),
            textAlign: TextAlign.center,
            child: content,
          ),
        );
}

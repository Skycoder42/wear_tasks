import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SideButton extends StatelessWidget {
  final bool filled;
  final VoidCallback? onPressed;
  final Widget icon;

  const SideButton({
    super.key,
    this.filled = false,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 24,
        height: 24,
        child: filled
            ? IconButton.filled(
                onPressed: onPressed,
                iconSize: 16,
                padding: EdgeInsets.zero,
                icon: icon,
              )
            : IconButton(
                onPressed: onPressed,
                iconSize: 16,
                padding: EdgeInsets.zero,
                icon: icon,
              ),
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('filled', filled))
      ..add(ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed));
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class InteractionDetector extends StatelessWidget {
  final VoidCallback onInteraction;
  final Widget child;

  const InteractionDetector({
    super.key,
    required this.onInteraction,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onInteraction,
        onPanDown: (_) => onInteraction(),
        onHorizontalDragStart: (_) => onInteraction(),
        onVerticalDragStart: (_) => onInteraction(),
        child: child,
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<VoidCallback>.has('onInteraction', onInteraction),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'side_button.dart';
import 'watch_scaffold.dart';

typedef ValueCallback<T> = T Function();

class WatchDialog<T> extends StatelessWidget {
  final bool horizontalSafeArea;
  final bool canAccept;
  final ValueCallback<T?>? onReject;
  final ValueCallback<T> onAccept;
  final Widget? bottomAction;
  final Widget body;

  const WatchDialog({
    super.key,
    this.horizontalSafeArea = false,
    this.canAccept = true,
    required this.onAccept,
    this.onReject,
    this.bottomAction,
    required this.body,
  });

  @override
  Widget build(BuildContext context) => WatchScaffold(
        horizontalSafeArea: horizontalSafeArea,
        leftAction: Padding(
          padding: const EdgeInsets.all(4),
          child: SideButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context, onReject?.call()),
          ),
        ),
        rightAction: Padding(
          padding: const EdgeInsets.all(4),
          child: SideButton(
            filled: true,
            icon: const Icon(Icons.check),
            onPressed:
                canAccept ? () => Navigator.pop(context, onAccept()) : null,
          ),
        ),
        bottomAction: bottomAction,
        body: body,
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ObjectFlagProperty<ValueCallback<T>>.has('onAccept', onAccept))
      ..add(ObjectFlagProperty<ValueCallback<T?>?>.has('onReject', onReject))
      ..add(
        DiagnosticsProperty<bool>('horizontalSafeArea', horizontalSafeArea),
      )
      ..add(DiagnosticsProperty<bool>('canAccept', canAccept));
  }
}

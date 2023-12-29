import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'side_button.dart';
import 'watch_scaffold.dart';

typedef ValueCallback<T> = T Function();

class WatchDialog<T> extends StatelessWidget {
  final ValueCallback<T?>? onReject;
  final ValueCallback<T> onAccept;
  final bool horizontalSafeArea;
  final Widget body;

  const WatchDialog({
    super.key,
    required this.onAccept,
    this.onReject,
    this.horizontalSafeArea = false,
    required this.body,
  });

  @override
  Widget build(BuildContext context) => WatchScaffold(
        horizontalSafeArea: horizontalSafeArea,
        leftAction: Padding(
          padding: const EdgeInsets.all(4),
          child: SideButton(
            icon: const Icon(Icons.close_outlined),
            onPressed: () => Navigator.pop(context, onReject?.call()),
          ),
        ),
        rightAction: Padding(
          padding: const EdgeInsets.all(4),
          child: SideButton(
            filled: true,
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.pop(context, onAccept()),
          ),
        ),
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
      );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app/watch_theme.dart';
import 'clock_bar.dart';
import 'events/rotary_event_source.dart';

typedef RotaryScrollHandler = bool Function(double scrollAxisValue);

class WatchScaffold extends HookConsumerWidget {
  final Widget? leftAction;
  final Widget? rightAction;
  final Widget? bottomAction;
  final bool showClock;
  final bool horizontalSafeArea;
  final bool loadingOverlayActive;
  final RotaryScrollHandler? rotaryScrollHandler;
  final Widget body;

  const WatchScaffold({
    super.key,
    this.leftAction,
    this.rightAction,
    this.bottomAction,
    this.showClock = true,
    this.horizontalSafeArea = false,
    this.loadingOverlayActive = false,
    this.rotaryScrollHandler,
    required this.body,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollHandlerCallback = useCallback<RotaryEventListener>(
      (event) => rotaryScrollHandler?.call(event.scrollAxisValue) ?? false,
      [rotaryScrollHandler],
    );

    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      body: Stack(
        children: [
          MediaQuery(
            data: mediaQuery.copyWith(
              padding: horizontalSafeArea
                  ? EdgeInsets.all(mediaQuery.padding.bottom)
                  : null,
            ),
            child: body,
          ),
          if (showClock)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClockBar(),
            ),
          if (bottomAction != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).padding.bottom,
                ),
                child: bottomAction,
              ),
            ),
          if (leftAction != null)
            Align(
              alignment: Alignment.centerLeft,
              child: leftAction,
            ),
          if (rightAction != null)
            Align(
              alignment: Alignment.centerRight,
              child: rightAction,
            ),
          if (loadingOverlayActive) ...[
            ModalBarrier(
              dismissible: false,
              color: context.theme.colorScheme.background.withOpacity(0.5),
            ),
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('showClock', showClock))
      ..add(
        DiagnosticsProperty<bool>('horizontalSafeArea', horizontalSafeArea),
      )
      ..add(
        DiagnosticsProperty<bool>(
          'loadingOverlayActive',
          loadingOverlayActive,
        ),
      )
      ..add(
        ObjectFlagProperty<RotaryScrollHandler?>.has(
          'rotaryScrollHandler',
          rotaryScrollHandler,
        ),
      );
  }
}

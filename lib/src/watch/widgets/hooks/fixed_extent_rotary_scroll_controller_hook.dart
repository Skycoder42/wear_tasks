import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wearable_rotary/wearable_rotary.dart';

class FixedExtentRotaryScrollController extends FixedExtentScrollController
    implements RotaryScrollController {
  @override
  final double maxIncrement;

  bool enabled = true;

  StreamSubscription<RotaryEvent>? _subscription;

  FixedExtentRotaryScrollController({
    super.initialItem,
    super.onAttach,
    super.onDetach,
    this.maxIncrement = 50,
  });

  @override
  void attach(ScrollPosition position) {
    _subscription ??= rotaryEvents.listen(_onRotaryEvent);
    super.attach(position);
  }

  @override
  void detach(ScrollPosition position) {
    unawaited(_subscription?.cancel());
    super.detach(position);
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  void _onRotaryEvent(RotaryEvent event) {
    if (!enabled) {
      return;
    }

    final double increment = min(event.magnitude ?? maxIncrement, maxIncrement);

    final double newOffset;
    if (event.direction == RotaryDirection.clockwise) {
      newOffset = min(offset + increment, position.maxScrollExtent);
    } else {
      newOffset = max(offset - increment, position.minScrollExtent);
    }
    jumpTo(newOffset);
  }
}

FixedExtentRotaryScrollController useFixedExtendRotaryScrollController({
  int initialItem = 0,
  double maxIncrement = 50,
  bool enabled = true,
}) =>
    use(
      _FixedExtentRotaryScrollControllerHook(
        initialItem,
        maxIncrement,
        enabled,
      ),
    );

class _FixedExtentRotaryScrollControllerHook
    extends Hook<FixedExtentRotaryScrollController> {
  final int initialItem;
  final double maxIncrement;
  final bool enabled;

  const _FixedExtentRotaryScrollControllerHook(
    this.initialItem,
    this.maxIncrement,
    this.enabled,
  );

  @override
  _FixedExtentRotaryScrollControllerHookState createState() =>
      _FixedExtentRotaryScrollControllerHookState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('initialItem', initialItem))
      ..add(DoubleProperty('maxIncrement', maxIncrement))
      ..add(DiagnosticsProperty<bool>('enabled', enabled));
  }
}

class _FixedExtentRotaryScrollControllerHookState extends HookState<
    FixedExtentRotaryScrollController, _FixedExtentRotaryScrollControllerHook> {
  late FixedExtentRotaryScrollController _controller;

  @override
  void initHook() {
    super.initHook();
    _controller = FixedExtentRotaryScrollController(
      initialItem: hook.initialItem,
      maxIncrement: hook.maxIncrement,
    )..enabled = hook.enabled;
  }

  @override
  void didUpdateHook(_FixedExtentRotaryScrollControllerHook oldHook) {
    super.didUpdateHook(oldHook);
    _controller.enabled = hook.enabled;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  FixedExtentRotaryScrollController build(BuildContext context) => _controller;
}

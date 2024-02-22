import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wearable_rotary/wearable_rotary.dart';

class _ConfigurableRotaryScrollController extends ScrollController
    implements RotaryScrollController {
  @override
  final double maxIncrement;

  bool enabled = true;

  StreamSubscription<RotaryEvent>? _subscription;

  _ConfigurableRotaryScrollController({
    this.maxIncrement = 50,
    super.initialScrollOffset,
  });

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
}

RotaryScrollController useRotaryScrollController({
  double maxIncrement = 50,
  double initialScrollOffset = 0,
  bool enabled = true,
}) =>
    use(
      _RotaryScrollControllerHook(
        maxIncrement,
        initialScrollOffset,
        enabled,
      ),
    );

class _RotaryScrollControllerHook extends Hook<RotaryScrollController> {
  final double maxIncrement;
  final double initialScrollOffset;
  final bool enabled;

  const _RotaryScrollControllerHook(
    this.maxIncrement,
    this.initialScrollOffset,
    this.enabled,
  );

  @override
  _RotaryScrollControllerHookState createState() =>
      _RotaryScrollControllerHookState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('maxIncrement', maxIncrement))
      ..add(DoubleProperty('initialScrollOffset', initialScrollOffset))
      ..add(DiagnosticsProperty<bool>('enabled', enabled));
  }
}

class _RotaryScrollControllerHookState
    extends HookState<RotaryScrollController, _RotaryScrollControllerHook> {
  late _ConfigurableRotaryScrollController _controller;

  @override
  void initHook() {
    super.initHook();
    _controller = _ConfigurableRotaryScrollController(
      maxIncrement: hook.maxIncrement,
      initialScrollOffset: hook.initialScrollOffset,
    )..enabled = hook.enabled;
  }

  @override
  void didUpdateHook(_RotaryScrollControllerHook oldHook) {
    super.didUpdateHook(oldHook);
    _controller.enabled = hook.enabled;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  RotaryScrollController build(BuildContext context) => _controller;
}

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wearable_rotary/wearable_rotary.dart';

abstract interface class ConfigurableRotaryScrollController
    implements RotaryScrollController {
  bool get enabled;
  set enabled(bool enabled);
}

mixin ConfigurableRotaryScrollControllerMixin on ScrollController
    implements ConfigurableRotaryScrollController {
  @override
  bool enabled = true;

  StreamSubscription<RotaryEvent>? _subscription;

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

typedef ScrollControllerFactory<
        TScrollController extends ConfigurableRotaryScrollController>
    = TScrollController Function();

TScrollController useGenericRotaryScrollController<
        TScrollController extends ConfigurableRotaryScrollController>(
  ScrollControllerFactory<TScrollController> createController, {
  bool enabled = true,
  bool requireActive = true,
}) =>
    use(
      _RotaryScrollControllerHook<TScrollController>(
        createController,
        enabled,
        requireActive,
      ),
    );

class _RotaryScrollControllerHook<
        TScrollController extends ConfigurableRotaryScrollController>
    extends Hook<TScrollController> {
  final ScrollControllerFactory<TScrollController> createController;
  final bool enabled;
  final bool requireActive;

  const _RotaryScrollControllerHook(
    this.createController,
    this.enabled,
    this.requireActive,
  );

  @override
  _RotaryScrollControllerHookState<TScrollController> createState() =>
      _RotaryScrollControllerHookState<TScrollController>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        ObjectFlagProperty<ScrollControllerFactory<TScrollController>>.has(
          'createController',
          createController,
        ),
      )
      ..add(DiagnosticsProperty<bool>('enabled', enabled))
      ..add(DiagnosticsProperty<bool>('requireActive', requireActive));
  }
}

class _RotaryScrollControllerHookState<
        TScrollController extends ConfigurableRotaryScrollController>
    extends HookState<TScrollController,
        _RotaryScrollControllerHook<TScrollController>> {
  late TScrollController _controller;

  bool _isActive = false;

  @override
  void initHook() {
    super.initHook();
    _controller = hook.createController();
    _updateEnabled();
  }

  @override
  void didUpdateHook(_RotaryScrollControllerHook<TScrollController> oldHook) {
    super.didUpdateHook(oldHook);
    _updateEnabled();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  TScrollController build(BuildContext context) {
    final route = ModalRoute.of(context);
    _isActive = route?.isCurrent ?? false;
    _updateEnabled();
    return _controller;
  }

  void _updateEnabled() {
    _controller.enabled = hook.enabled && (!hook.requireActive || _isActive);
  }
}

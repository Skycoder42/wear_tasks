import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void useTimer(
  Duration timeout,
  VoidCallback onTimeout, {
  bool enabled = true,
  bool periodic = false,
}) =>
    use(_TimerHook(enabled, timeout, periodic, onTimeout));

class _TimerHook extends Hook<void> {
  final bool enabled;
  final Duration timeout;
  final bool periodic;
  final VoidCallback onTimeout;

  const _TimerHook(
    this.enabled,
    this.timeout,
    this.periodic,
    this.onTimeout,
  );

  @override
  _TimerHookState createState() => _TimerHookState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('enabled', enabled))
      ..add(DiagnosticsProperty<Duration>('timeout', timeout))
      ..add(DiagnosticsProperty<bool>('periodic', periodic))
      ..add(ObjectFlagProperty<VoidCallback>.has('onTimeout', onTimeout));
  }
}

class _TimerHookState extends HookState<void, _TimerHook> {
  Timer? _timer;

  @override
  void initHook() {
    super.initHook();
    _timer = _createTimer();
  }

  @override
  void didUpdateHook(_TimerHook oldHook) {
    super.didUpdateHook(oldHook);
    if (hook.enabled != oldHook.enabled ||
        hook.timeout != oldHook.timeout ||
        hook.periodic != oldHook.periodic ||
        hook.onTimeout != oldHook.onTimeout) {
      _timer?.cancel();
      _timer = _createTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void build(BuildContext context) {}

  Timer? _createTimer() => hook.enabled
      ? (hook.periodic
          ? Timer.periodic(hook.timeout, (_) => hook.onTimeout())
          : Timer(hook.timeout, hook.onTimeout))
      : null;
}

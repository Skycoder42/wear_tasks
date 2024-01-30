import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// ignore: no_self_package_imports
import '../../../../gen/pigeons/rotary_input.pigeon.dart';

part 'rotary_input_hook.g.dart';

@Riverpod(keepAlive: true)
RotaryInputEventHandler rotaryInputEventHandler(
  RotaryInputEventHandlerRef ref,
) {
  final handler = RotaryInputEventHandler();
  RotaryInput.setup(handler);
  ref.onDispose(() => RotaryInput.setup(null));
  return handler;
}

typedef RotaryEventHandler = bool Function(double scrollAxisValue);

class RotaryInputEventHandler extends RotaryInput {
  final _listeners = <RotaryEventHandler>[];

  @override
  void handleRotaryEvent(RotaryEvent event) {
    for (final handler in _listeners.reversed) {
      if (handler(event.scrollAxisValue)) {
        return;
      }
    }
  }

  void addListener(RotaryEventHandler handler) => _listeners.add(handler);

  void removeListener(RotaryEventHandler handler) => _listeners.remove(handler);
}

void useRotaryEvents(WidgetRef ref, RotaryEventHandler handler) {
  use(_RotaryInputHook(ref, handler));
}

class _RotaryInputHook extends Hook<void> {
  final WidgetRef ref;
  final RotaryEventHandler handler;

  const _RotaryInputHook(this.ref, this.handler);

  @override
  _RotaryInputHookState createState() => _RotaryInputHookState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<WidgetRef>('ref', ref))
      ..add(ObjectFlagProperty<RotaryEventHandler>.has('handler', handler));
  }
}

class _RotaryInputHookState extends HookState<void, _RotaryInputHook> {
  @override
  void initHook() {
    super.initHook();
    hook.ref.watch(rotaryInputEventHandlerProvider).addListener(hook.handler);
  }

  @override
  void dispose() {
    hook.ref.read(rotaryInputEventHandlerProvider).removeListener(hook.handler);
    super.dispose();
  }

  @override
  void didUpdateHook(_RotaryInputHook oldHook) {
    super.didUpdateHook(oldHook);

    final oldHandler = oldHook.ref.read(rotaryInputEventHandlerProvider);
    final newHandler = hook.ref.watch(rotaryInputEventHandlerProvider);

    if (newHandler != oldHandler || hook.handler != oldHook.handler) {
      oldHandler.removeListener(oldHook.handler);
      newHandler.addListener(hook.handler);
    }
  }

  @override
  void build(BuildContext context) {}
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

// ignore: no_self_package_imports
import '../../../../gen/pigeons/rotary_input.pigeon.dart';

part 'rotary_event_source.g.dart';

typedef RotaryEventListener = bool Function(RotaryEvent event);

@Riverpod(keepAlive: true)
RotaryEventSource rotaryEventSource(RotaryEventSourceRef ref) {
  final handler = RotaryEventSource();
  RotaryInput.setup(handler);
  ref.onDispose(() => RotaryInput.setup(null));
  return handler;
}

class RotaryEventSource extends RotaryInput {
  final _listeners = <RotaryEventListener>[];

  void addListener(RotaryEventListener listener) => _listeners.add(listener);

  void removeListener(RotaryEventListener listener) =>
      _listeners.remove(listener);

  @override
  void handleRotaryEvent(RotaryEvent event) {
    for (final listener in _listeners.reversed) {
      if (listener(event)) {
        return;
      }
    }
  }
}

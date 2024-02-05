import 'package:logging/logging.dart';
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
  final _logger = Logger('$RotaryEventSource');

  void addListener(RotaryEventListener listener) => _listeners.add(listener);

  void removeListener(RotaryEventListener listener) =>
      _listeners.remove(listener);

  @override
  void handleRotaryEvent(RotaryEvent event) {
    _logger.finer('Handling rotary event: ${event.encode()}');

    for (final listener in _listeners.reversed) {
      try {
        if (listener(event)) {
          return;
        }

        // ignore: avoid_catches_without_on_clauses
      } catch (e, s) {
        _logger.severe('Rotary event handler threw', e, s);
      }
    }
  }
}

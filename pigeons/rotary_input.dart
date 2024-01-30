import 'package:pigeon/pigeon.dart';

class RotaryEvent {
  final double scrollAxisValue;

  const RotaryEvent(this.scrollAxisValue);
}

@FlutterApi()
abstract class RotaryInput {
  void handleRotaryEvent(RotaryEvent event);
}

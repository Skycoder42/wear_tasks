import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

FixedExtentScrollController useFixedExtentScrollController({
  int initialIndex = 0,
}) =>
    use(_FixedExtentScrollControllerHook(initialIndex));

class _FixedExtentScrollControllerHook
    extends Hook<FixedExtentScrollController> {
  final int initialIndex;

  const _FixedExtentScrollControllerHook(this.initialIndex);

  @override
  _FixedExtentScrollControllerHookState createState() =>
      _FixedExtentScrollControllerHookState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('initialIndex', initialIndex));
  }
}

class _FixedExtentScrollControllerHookState extends HookState<
    FixedExtentScrollController, _FixedExtentScrollControllerHook> {
  late FixedExtentScrollController _controller;

  @override
  void initHook() {
    super.initHook();
    _controller = FixedExtentScrollController(
      initialItem: hook.initialIndex,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  FixedExtentScrollController build(BuildContext context) => _controller;
}

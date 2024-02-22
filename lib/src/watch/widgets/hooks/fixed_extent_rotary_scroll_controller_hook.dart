import 'package:flutter/widgets.dart';
import 'package:wearable_rotary/wearable_rotary.dart';

import 'generic_rotary_scroll_controller_hook.dart';

abstract interface class FixedExtentRotaryScrollController
    implements FixedExtentScrollController, RotaryScrollController {}

class _FixedExtentRotaryScrollController extends FixedExtentScrollController
    with ConfigurableRotaryScrollControllerMixin
    implements FixedExtentRotaryScrollController {
  @override
  final double maxIncrement;

  _FixedExtentRotaryScrollController({
    super.initialItem,
    this.maxIncrement = 50,
  });
}

FixedExtentRotaryScrollController useFixedExtendRotaryScrollController({
  int initialItem = 0,
  double maxIncrement = 50,
  bool enabled = true,
  bool requireActive = true,
}) =>
    useGenericRotaryScrollController<_FixedExtentRotaryScrollController>(
      () => _FixedExtentRotaryScrollController(
        initialItem: initialItem,
        maxIncrement: maxIncrement,
      ),
      enabled: enabled,
      requireActive: requireActive,
    );

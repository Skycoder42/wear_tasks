import 'package:flutter/widgets.dart';
import 'package:wearable_rotary/wearable_rotary.dart';

import 'generic_rotary_scroll_controller_hook.dart';

class _ConfigurableRotaryScrollController extends ScrollController
    with ConfigurableRotaryScrollControllerMixin {
  @override
  final double maxIncrement;

  _ConfigurableRotaryScrollController({
    this.maxIncrement = 50,
    super.initialScrollOffset,
  });
}

RotaryScrollController useRotaryScrollController({
  double maxIncrement = 50,
  double initialScrollOffset = 0,
  bool enabled = true,
  bool requireActive = true,
}) =>
    useGenericRotaryScrollController<_ConfigurableRotaryScrollController>(
      () => _ConfigurableRotaryScrollController(
        maxIncrement: maxIncrement,
        initialScrollOffset: initialScrollOffset,
      ),
      enabled: enabled,
      requireActive: requireActive,
    );

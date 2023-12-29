import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/task.dart';
import '../../widgets/side_button.dart';

typedef PriorityChangedCallback = void Function(TaskPriority priority);

class PriorityButton extends HookConsumerWidget {
  static const _animationDuration = Duration(milliseconds: 250);
  static const _animationCurve = Curves.easeInOut;

  final TaskPriority currentPriority;
  final PriorityChangedCallback onPriorityChanged;

  const PriorityButton({
    super.key,
    required this.currentPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = useState(false);
    final animationController = useAnimationController(
      duration: _animationDuration,
    );
    final animation = useMemoized(
      () => CurvedAnimation(
        parent: animationController,
        curve: _animationCurve,
      ),
      [animationController],
    );
    final sizeAnimation = useMemoized(
      () => Tween<double>(begin: 32, end: 4 + TaskPriority.values.length * 28)
          .animate(animation),
      [animation],
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Container(
        height: 32,
        width: sizeAnimation.value,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 4 * animation.value,
            sigmaY: 4 * animation.value,
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                for (final priority in TaskPriority.values)
                  Positioned(
                    left: priority.index * 28 * animation.value,
                    child: Opacity(
                      opacity:
                          priority == currentPriority ? 1 : animation.value,
                      child: Offstage(
                        offstage: animation.value == 0.0 &&
                            priority != currentPriority,
                        child: SideButton(
                          icon: priority.icon,
                          onPressed: () {
                            if (isActive.value) {
                              onPriorityChanged(priority);
                              isActive.value = false;
                              animationController.reverse();
                            } else {
                              isActive.value = true;
                              animationController.forward();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<TaskPriority>('currentPriority', currentPriority))
      ..add(
        ObjectFlagProperty<PriorityChangedCallback>.has(
          'onPriorityChanged',
          onPriorityChanged,
        ),
      );
  }
}

extension on TaskPriority {
  Icon get icon => switch (this) {
        TaskPriority.none => const Icon(Icons.notifications_off_outlined),
        TaskPriority.low => const Icon(
            Icons.notifications_outlined,
            color: Colors.blue,
          ),
        TaskPriority.medium => const Icon(
            Icons.notifications_active_outlined,
            color: Colors.orange,
          ),
        TaskPriority.high => const Icon(
            Icons.notification_important_outlined,
            color: Colors.red,
          ),
      };
}

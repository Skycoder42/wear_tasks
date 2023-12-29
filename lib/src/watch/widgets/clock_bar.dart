import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../common/localization/localization.dart';
import '../app/watch_theme.dart';
import 'hooks/timer_hook.dart';

class ClockBar extends HookWidget {
  const ClockBar({super.key});

  @override
  Widget build(BuildContext context) {
    final now = useState(DateTime.now());
    final minuteOffset = useMemoized(() {
      final next = now.value.copyWith(
        minute: now.value.minute + 1,
        second: 0,
        millisecond: 0,
        microsecond: 0,
      );
      return next.difference(now.value);
    });

    final timerDuration = useState(minuteOffset);
    final onTimeout = useCallback(
      () {
        timerDuration.value = const Duration(minutes: 1);
        now.value = DateTime.now();
      },
      [timerDuration, now],
    );

    useTimer(
      periodic: true,
      timerDuration.value,
      onTimeout,
    );

    return Container(
      decoration: const BoxDecoration(),
      clipBehavior: Clip.hardEdge,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            context.strings.clock_bar_time(now.value),
            textAlign: TextAlign.center,
            style: context.theme.textTheme.bodySmall,
          ),
        ),
      ),
    );
  }
}

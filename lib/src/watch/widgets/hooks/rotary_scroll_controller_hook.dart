import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../events/rotary_event_source.dart';
import 'fixed_extent_scroll_controller_hook.dart';
import 'rotary_events_hook.dart';

class _ScrollState {
  final double scrollStart;
  final double scrollDelta;
  final Future<void> future;

  _ScrollState(
    this.scrollStart,
    this.scrollDelta,
    this.future,
  );
}

void useRotaryScrollHandler(
  WidgetRef ref,
  ScrollController scrollController, {
  double itemExtend = 50,
  bool enabled = true,
}) {
  final scrollState = useRef<_ScrollState?>(null);
  final scrollHandler = useCallback<RotaryEventListener>(
    (event) {
      if (!enabled) {
        return false;
      }

      final scrollOffset = scrollController.offset;
      var scrollDelta = event.scrollAxisValue * -1 * itemExtend;
      if (scrollState.value case final _ScrollState state) {
        scrollDelta += state.scrollDelta - (scrollOffset - state.scrollStart);
      }

      // ignore: discarded_futures
      final animateTo = scrollController.animateTo(
        scrollOffset + scrollDelta,
        duration: const Duration(milliseconds: 100),
        curve: Curves.linear,
      );
      scrollState.value = _ScrollState(
        scrollOffset,
        scrollDelta,
        animateTo,
      );
      unawaited(
        animateTo.whenComplete(() {
          if (identical(scrollState.value?.future, animateTo)) {
            scrollState.value = null;
          }
        }),
      );
      return true;
    },
    [scrollController, scrollState, enabled],
  );
  useRotaryEvents(ref, scrollHandler);
}

ScrollController useRotaryScrollController(
  WidgetRef ref, {
  double itemExtend = 50,
  bool enabled = true,
  double initialScrollOffset = 0.0,
  bool keepScrollOffset = true,
  String? debugLabel,
  List<Object?>? keys,
}) {
  final scrollController = useScrollController(
    initialScrollOffset: initialScrollOffset,
    keepScrollOffset: keepScrollOffset,
    debugLabel: debugLabel,
    keys: keys,
  );
  useRotaryScrollHandler(
    ref,
    scrollController,
    itemExtend: itemExtend,
    enabled: enabled,
  );
  return scrollController;
}

FixedExtentScrollController useRotaryFixedExtentScrollController(
  WidgetRef ref, {
  required double itemExtend,
  bool enabled = true,
  int initialIndex = 0,
}) {
  final scrollController = useFixedExtentScrollController(
    initialIndex: initialIndex,
  );
  useRotaryScrollHandler(
    ref,
    scrollController,
    itemExtend: itemExtend,
    enabled: enabled,
  );
  return scrollController;
}

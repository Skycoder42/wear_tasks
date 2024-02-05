import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// ignore: no_self_package_imports
import '../../../../gen/pigeons/rotary_input.pigeon.dart';
import '../events/rotary_event_source.dart';

void useRotaryEvents(
  WidgetRef ref,
  RotaryEventListener handler, {
  bool requireActive = true,
}) {
  use(
    _RotaryInputHook(
      ref.watch(rotaryEventSourceProvider),
      requireActive,
      handler,
    ),
  );
}

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

ScrollController useRotaryScrollController(WidgetRef ref) {
  final scrollState = useRef<_ScrollState?>(null);
  final scrollController = useScrollController();
  final scrollHandler = useCallback<RotaryEventListener>(
    (event) {
      final scrollOffset = scrollController.offset;
      var scrollDelta = event.scrollAxisValue * 50;
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
    [scrollController, scrollState],
  );
  useRotaryEvents(ref, scrollHandler);
  return scrollController;
}

class _RotaryInputHook extends Hook<void> {
  final RotaryEventSource eventSource;
  final bool requireActive;
  final RotaryEventListener handler;

  const _RotaryInputHook(this.eventSource, this.requireActive, this.handler);

  @override
  _RotaryInputHookState createState() => _RotaryInputHookState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      ..add(
        ObjectFlagProperty<RotaryEventSource>.has(
          'inputHandler',
          eventSource,
        ),
      )
      ..add(DiagnosticsProperty<bool>('requireActive', requireActive))
      ..add(ObjectFlagProperty<RotaryEventListener>.has('handler', handler));
  }
}

class _RotaryInputHookState extends HookState<void, _RotaryInputHook> {
  bool _isActive = false;

  bool call(RotaryEvent event) {
    if (hook.requireActive && !_isActive) {
      return false;
    }

    return hook.handler(event);
  }

  @override
  void initHook() {
    super.initHook();
    hook.eventSource.addListener(call);
  }

  @override
  void dispose() {
    hook.eventSource.removeListener(call);
    super.dispose();
  }

  @override
  void didUpdateHook(_RotaryInputHook oldHook) {
    super.didUpdateHook(oldHook);
    if (hook.eventSource != oldHook.eventSource) {
      oldHook.eventSource.removeListener(call);
      hook.eventSource.addListener(call);
    }
  }

  @override
  void build(BuildContext context) {
    final route = ModalRoute.of(context);
    _isActive = route?.isCurrent ?? false;
  }
}

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// starts at the 2pm marker on an analog watch
const _kProgressBarStartingPoint = math.pi * (-1 / 2 + 1 / 3);
// finishes at the 4pm marker on an analog watch
const _kProgressBarLength = math.pi / 3;

class WatchScrollbar extends StatefulWidget {
  /// ScrollController for the scrollbar.
  final ScrollController controller;

  /// Padding between edges of screen and scrollbar track.
  final double padding;

  /// Width of scrollbar track and thumb.
  final double width;

  /// Whether scrollbar should hide automatically if inactive.
  final bool autoHide;

  /// Animation curve for the showing/hiding animation.
  final Curve opacityAnimationCurve;

  /// Animation duration for the showing/hiding animation.
  final Duration opacityAnimationDuration;

  /// How long scrollbar is displayed after a scroll event.
  final Duration autoHideDuration;

  /// Overrides color of the scrollbar track.
  final Color? trackColor;

  /// Overrides color of the scrollbar thumb.
  final Color? thumbColor;

  final Widget child;

  /// A scrollbar which curves around circular screens.
  /// Similar to native wearOS scrollbar in devices with round screens.
  const WatchScrollbar({
    super.key,
    required this.controller,
    this.padding = 6,
    this.width = 6,
    this.autoHide = true,
    this.opacityAnimationCurve = Curves.easeInOut,
    this.opacityAnimationDuration = const Duration(milliseconds: 250),
    this.autoHideDuration = const Duration(seconds: 3),
    this.trackColor,
    this.thumbColor,
    required this.child,
  });

  @override
  State<WatchScrollbar> createState() => _WatchScrollbarState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ScrollController>('controller', controller))
      ..add(DoubleProperty('padding', padding))
      ..add(DoubleProperty('width', width))
      ..add(DiagnosticsProperty<bool>('autoHide', autoHide))
      ..add(
        DiagnosticsProperty<Curve>(
          'opacityAnimationCurve',
          opacityAnimationCurve,
        ),
      )
      ..add(
        DiagnosticsProperty<Duration>(
          'opacityAnimationDuration',
          opacityAnimationDuration,
        ),
      )
      ..add(
        DiagnosticsProperty<Duration>('autoHideDuration', autoHideDuration),
      )
      ..add(ColorProperty('trackColor', trackColor))
      ..add(ColorProperty('thumbColor', thumbColor));
  }
}

class _WatchScrollbarState extends State<WatchScrollbar> {
  double? _index;
  double? _fractionOfThumb;

  bool _isScrollBarVisible = false;
  Timer? _hideTimer;

  void _onScrolled() {
    if (!widget.controller.hasClients) return;

    setState(() {
      _isScrollBarVisible = true;
      _updateScrollValues();
    });

    _hideAfterDelay();
  }

  void _hideAfterDelay() {
    if (!widget.autoHide) return;

    _hideTimer?.cancel();
    _hideTimer = Timer(
      widget.autoHideDuration,
      () => setState(() => _isScrollBarVisible = false),
    );
  }

  void _updateScrollValues() {
    if (!widget.controller.hasClients) {
      return;
    }

    _fractionOfThumb = 1 /
        ((widget.controller.position.maxScrollExtent /
                widget.controller.position.viewportDimension) +
            1);

    _index =
        widget.controller.offset / widget.controller.position.viewportDimension;
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScrolled);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollValues());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScrolled);
    _hideTimer?.cancel();
    super.dispose();
  }

  Widget _addAnimatedOpacity({required Widget child}) {
    if (!widget.autoHide) return child;

    return AnimatedOpacity(
      opacity: _isScrollBarVisible ? 1 : 0,
      duration: widget.opacityAnimationDuration,
      curve: widget.opacityAnimationCurve,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          widget.child,
          if (_index != null && _fractionOfThumb != null)
            IgnorePointer(
              child: _addAnimatedOpacity(
                child: Stack(
                  children: [
                    _WatchScrollbarTrack(
                      padding: widget.padding,
                      width: widget.width,
                      color: widget.trackColor,
                    ),
                    _WatchScrollbarThumb(
                      padding: widget.padding,
                      width: widget.width,
                      fraction: _fractionOfThumb!,
                      index: _index!,
                      color: widget.thumbColor,
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
}

class _WatchScrollbarTrack extends StatelessWidget {
  final double padding;
  final double width;
  final Color? color;

  const _WatchScrollbarTrack({
    required this.padding,
    required this.width,
    this.color,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _WatchScrollbarPainter(
          angleLength: _kProgressBarLength,
          color: color ?? Theme.of(context).highlightColor,
          startingAngle: _kProgressBarStartingPoint,
          trackPadding: padding,
          trackWidth: width,
        ),
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('padding', padding))
      ..add(DoubleProperty('width', width))
      ..add(ColorProperty('color', color));
  }
}

class _WatchScrollbarThumb extends StatelessWidget {
  final double padding;
  final double width;
  final Color? color;
  final double fraction;
  final double index;

  const _WatchScrollbarThumb({
    required this.padding,
    required this.width,
    required this.fraction,
    required this.index,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final angleLength = _kProgressBarLength * fraction;
    return Transform.rotate(
      angle: index * angleLength,
      child: CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _WatchScrollbarPainter(
          angleLength: angleLength,
          startingAngle: _kProgressBarStartingPoint,
          color: color ?? Theme.of(context).highlightColor.withOpacity(1.0),
          trackPadding: padding,
          trackWidth: width,
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('padding', padding))
      ..add(DoubleProperty('width', width))
      ..add(ColorProperty('color', color))
      ..add(DoubleProperty('fraction', fraction))
      ..add(DoubleProperty('index', index));
  }
}

class _WatchScrollbarPainter extends CustomPainter {
  final double startingAngle;
  final double angleLength;
  final Color color;
  final double trackWidth;
  final double trackPadding;

  _WatchScrollbarPainter({
    required this.angleLength,
    required this.color,
    required this.trackPadding,
    required this.trackWidth,
    this.startingAngle = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = trackWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerOffset = Offset(
      size.width / 2,
      size.height / 2,
    );

    final innerWidth = size.width - trackPadding * 2 - trackWidth;
    final innerHeight = size.height - trackPadding * 2 - trackWidth;

    final path = Path()
      ..arcTo(
        Rect.fromCenter(
          center: centerOffset,
          width: innerWidth,
          height: innerHeight,
        ),
        startingAngle,
        angleLength,
        true,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WatchScrollbarPainter oldDelegate) =>
      color != oldDelegate.color ||
      startingAngle != oldDelegate.startingAngle ||
      angleLength != oldDelegate.angleLength ||
      trackWidth != oldDelegate.trackWidth ||
      trackPadding != oldDelegate.trackPadding;
}

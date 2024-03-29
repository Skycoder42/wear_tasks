import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'side_button.dart';
import 'watch_scaffold.dart';

typedef ValueCallback<T> = T Function();
typedef PageChangedCallback = void Function(int);

class WatchDialog<T> extends HookWidget {
  static const animationDuration = Duration(milliseconds: 250);
  static const animationCurve = Curves.easeInOut;

  final bool horizontalSafeArea;
  final bool loadingOverlayActive;
  final ValueCallback<T?>? onReject;
  final ValueCallback<T> onAccept;
  final PageChangedCallback? onPageChanged;
  final IndexedWidgetBuilder? bottomActionBuilder;
  final List<Widget> pages;
  final List<bool>? pageValidations;

  bool get _isSinglePage => pages.length == 1;

  WatchDialog({
    super.key,
    this.horizontalSafeArea = false,
    this.loadingOverlayActive = false,
    bool canAccept = true,
    required this.onAccept,
    this.onReject,
    Widget? bottomAction,
    required Widget body,
  })  : pages = [body],
        pageValidations = [canAccept],
        bottomActionBuilder = _singleBottomActionBuilder(bottomAction),
        onPageChanged = null;

  WatchDialog.paged({
    super.key,
    this.horizontalSafeArea = false,
    this.loadingOverlayActive = false,
    required this.onAccept,
    this.onReject,
    this.onPageChanged,
    this.bottomActionBuilder,
    required this.pages,
    this.pageValidations,
  })  : assert(pages.isNotEmpty, 'pages must not be empty'),
        assert(
          pageValidations == null || pageValidations.length == pages.length,
          'pageValidations must be null or have as many elements as pages',
        );

  @override
  Widget build(BuildContext context) {
    final pageController = usePageController();
    final activePage = useState(0);

    useEffect(
      () {
        if (onPageChanged case final PageChangedCallback cb) {
          scheduleMicrotask(() => cb(activePage.value));
        }
        return null;
      },
      [onPageChanged, activePage.value],
    );

    return PopScope(
      canPop: activePage.value == 0,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await pageController.previousPage(
            duration: animationDuration,
            curve: animationCurve,
          );
        }
      },
      child: WatchScaffold(
        horizontalSafeArea: horizontalSafeArea,
        loadingOverlayActive: loadingOverlayActive,
        leftAction: _buildButtonStack(pageController, [
          _buildRejectButton(context),
          for (var i = 1; i < pages.length; ++i)
            _buildPrevButton(pageController),
        ]),
        rightAction: _buildButtonStack(pageController, [
          for (var i = 0; i < pages.length - 1; ++i)
            _buildNextButton(pageController, pageValidations?[i] ?? true),
          _buildAcceptButton(context, pageValidations?.last ?? true),
        ]),
        bottomAction: bottomActionBuilder != null
            ? ValueListenableBuilder(
                valueListenable: activePage,
                builder: (context, page, _) =>
                    bottomActionBuilder!(context, page),
              )
            : null,
        body: _isSinglePage
            ? pages.single
            : PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (value) => activePage.value = value,
                children: pages,
              ),
      ),
    );
  }

  SideButton _buildAcceptButton(BuildContext context, bool isPageValid) =>
      SideButton(
        filled: true,
        icon: const Icon(Icons.check),
        onPressed:
            isPageValid ? () => Navigator.pop(context, onAccept()) : null,
      );

  SideButton _buildRejectButton(BuildContext context) => SideButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.pop(context, onReject?.call()),
      );

  Widget _buildNextButton(PageController pageController, bool isPageValid) =>
      SideButton(
        icon: const Icon(Icons.chevron_right),
        onPressed: isPageValid
            ? () async => pageController.nextPage(
                  duration: animationDuration,
                  curve: animationCurve,
                )
            : null,
      );

  Widget _buildPrevButton(PageController pageController) => SideButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: () async => pageController.previousPage(
          duration: animationDuration,
          curve: animationCurve,
        ),
      );

  Widget _buildButtonStack(PageController controller, List<Widget> widgets) =>
      Padding(
        padding: const EdgeInsets.all(4),
        child: _isSinglePage
            ? widgets.single
            : ListenableBuilder(
                listenable: controller,
                builder: (context, _) => Stack(
                  children: [
                    for (final (index, widget) in widgets.indexed)
                      Offstage(
                        offstage: (index - (controller.page ?? 0.0)).abs() >= 1,
                        child: Opacity(
                          opacity: 1 -
                              min(
                                (index - (controller.page ?? 0.0)).abs(),
                                1.0,
                              ),
                          child: widget,
                        ),
                      ),
                  ],
                ),
              ),
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ObjectFlagProperty<ValueCallback<T>>.has('onAccept', onAccept))
      ..add(ObjectFlagProperty<ValueCallback<T?>?>.has('onReject', onReject))
      ..add(
        DiagnosticsProperty<bool>('horizontalSafeArea', horizontalSafeArea),
      )
      ..add(
        DiagnosticsProperty<bool>('loadingOverlayActive', loadingOverlayActive),
      )
      ..add(IterableProperty<bool>('pageValidations', pageValidations))
      ..add(
        ObjectFlagProperty<IndexedWidgetBuilder?>.has(
          'bottomActionBuilder',
          bottomActionBuilder,
        ),
      )
      ..add(
        ObjectFlagProperty<PageChangedCallback?>.has(
          'onPageChanged',
          onPageChanged,
        ),
      );
  }

  static IndexedWidgetBuilder? _singleBottomActionBuilder(Widget? widget) =>
      widget != null ? (_, __) => widget : null;
}

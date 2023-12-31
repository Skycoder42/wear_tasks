import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'side_button.dart';
import 'watch_scaffold.dart';

typedef ValueCallback<T> = T Function();

class WatchDialog<T> extends StatelessWidget {
  static const _animationDuration = Duration(milliseconds: 500);
  static const _animationCurve = Curves.easeInOut;

  final bool horizontalSafeArea;
  final ValueCallback<T?>? onReject;
  final ValueCallback<T> onAccept;
  final Widget? bottomAction;
  final List<Widget> pages;
  final List<bool>? pageValidations;

  WatchDialog({
    super.key,
    this.horizontalSafeArea = false,
    bool canAccept = true,
    required this.onAccept,
    this.onReject,
    this.bottomAction,
    required Widget body,
  })  : pages = [body],
        pageValidations = [canAccept];

  WatchDialog.paged({
    super.key,
    this.horizontalSafeArea = false,
    required this.onAccept,
    this.onReject,
    this.bottomAction,
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
    final isFirstPage = activePage.value == 0;
    final isLastPage = activePage.value == pages.length - 1;
    final isPageValid = pageValidations?[activePage.value] ?? true;

    return WatchScaffold(
      horizontalSafeArea: horizontalSafeArea,
      leftAction: Padding(
        padding: const EdgeInsets.all(4),
        child: SideButton(
          icon: isFirstPage
              ? const Icon(Icons.close)
              : const Icon(Icons.chevron_left),
          onPressed: () async {
            if (isFirstPage) {
              Navigator.pop(context, onReject?.call());
            } else {
              await pageController.previousPage(
                duration: _animationDuration,
                curve: _animationCurve,
              );
            }
          },
        ),
      ),
      rightAction: Padding(
        padding: const EdgeInsets.all(4),
        child: SideButton(
          filled: isLastPage,
          icon: isLastPage
              ? const Icon(Icons.check)
              : const Icon(Icons.chevron_right),
          onPressed: isPageValid
              ? () async {
                  if (isLastPage) {
                    Navigator.pop(context, onAccept());
                  } else {
                    await pageController.nextPage(
                      duration: _animationDuration,
                      curve: _animationCurve,
                    );
                  }
                }
              : null,
        ),
      ),
      bottomAction: bottomAction,
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (value) => activePage.value = value,
        children: pages,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ObjectFlagProperty<ValueCallback<T>>.has('onAccept', onAccept))
      ..add(ObjectFlagProperty<ValueCallback<T?>?>.has('onReject', onReject))
      ..add(
        DiagnosticsProperty<bool>('horizontalSafeArea', horizontalSafeArea),
      )
      ..add(IterableProperty<bool>('pageValidations', pageValidations));
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app/watch_theme.dart';
import 'side_button.dart';
import 'watch_app_bar.dart';

class WatchScaffold extends StatelessWidget {
  final Widget? title;
  final Widget? rightAction;
  final Widget? bottomAction;
  final bool horizontalSafeArea;
  final bool loadingOverlayActive;
  final Widget body;

  const WatchScaffold({
    super.key,
    this.title,
    this.rightAction,
    this.bottomAction,
    this.horizontalSafeArea = false,
    this.loadingOverlayActive = false,
    required this.body,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                if (title != null) WatchAppBar(title: title!),
                SliverToBoxAdapter(child: body),
              ],
            ),
            if (ModalRoute.of(context)?.impliesAppBarDismissal ?? false)
              Align(
                alignment: Alignment.centerLeft,
                child: SideButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () async => Navigator.maybePop(context),
                ),
              ),
            if (bottomAction != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).padding.bottom,
                  ),
                  child: bottomAction,
                ),
              ),
            if (rightAction != null)
              Align(
                alignment: Alignment.centerRight,
                child: rightAction,
              ),
            if (loadingOverlayActive) ...[
              ModalBarrier(
                dismissible: false,
                color: context.theme.colorScheme.background.withOpacity(0.5),
              ),
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ],
        ),
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<bool>('horizontalSafeArea', horizontalSafeArea),
      )
      ..add(
        DiagnosticsProperty<bool>(
          'loadingOverlayActive',
          loadingOverlayActive,
        ),
      );
  }
}

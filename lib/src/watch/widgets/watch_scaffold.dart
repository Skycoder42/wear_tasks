import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app/watch_theme.dart';
import 'watch_app_bar.dart';

class WatchScaffold extends StatelessWidget {
  final Widget? title;
  final Widget body;
  final bool loadingOverlayActive;

  const WatchScaffold({
    super.key,
    this.title,
    required this.body,
    this.loadingOverlayActive = false,
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
    properties.add(
      DiagnosticsProperty<bool>(
        'loadingOverlayActive',
        loadingOverlayActive,
      ),
    );
  }
}

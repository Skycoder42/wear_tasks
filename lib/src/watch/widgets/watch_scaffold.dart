import 'package:flutter/material.dart';

import 'watch_app_bar.dart';

class WatchScaffold extends StatelessWidget {
  final Widget? title;
  final Widget body;

  const WatchScaffold({
    super.key,
    this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        body: CustomScrollView(
          slivers: [
            if (title != null) WatchAppBar(title: title!),
            SliverToBoxAdapter(child: body),
          ],
        ),
      );
}

import 'package:flutter/material.dart';

class WatchAppBar extends StatelessWidget {
  final Widget title;

  const WatchAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) => SliverAppBar(
        pinned: true,
        toolbarHeight: 8,
        collapsedHeight: 8,
        expandedHeight: 32,
        automaticallyImplyLeading: false,
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.only(bottom: 8),
          title: title,
          centerTitle: true,
        ),
      );
}

import 'dart:math';

import 'package:flutter/material.dart';

class WatchScaffold extends StatelessWidget {
  final Widget body;

  const WatchScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final diameter = min(mediaQuery.size.width, mediaQuery.size.height);
    final padding = (diameter - ((diameter / 2) * sqrt2)) / 2;
    return Scaffold(
      body: MediaQuery(
        data: mediaQuery.copyWith(
          padding: EdgeInsets.all(padding),
        ),
        child: body,
      ),
    );
  }
}

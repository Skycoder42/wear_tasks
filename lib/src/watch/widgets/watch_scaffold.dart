import 'package:flutter/material.dart';

class WatchScaffold extends StatelessWidget {
  final Widget body;

  const WatchScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: body,
      );
}

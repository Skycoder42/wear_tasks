import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton.icon(
                icon: const Icon(Icons.abc),
                label: const Text('Hello World!'),
                onPressed: () async => _etebaseInit(context),
              ),
            ),
          ),
        ),
      );

  Future<void> _etebaseInit(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    final client = await EtebaseClient.create(
      'wear_tasks',
      Uri.https('etebase.skycoder42.de'),
    );
    final serverOk = await client.checkEtebaseServer();

    messenger.showSnackBar(
      SnackBar(
        content: Center(
          child: Text('Server: $serverOk'),
        ),
      ),
    );
  }
}

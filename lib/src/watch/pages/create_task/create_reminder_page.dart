import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../widgets/watch_scaffold.dart';
import 'collection_selector_button.dart';

class CreateTaskPage extends HookConsumerWidget {
  static const createButtonHeroTag = 'CreateTaskPage.createButtonHero';

  const CreateTaskPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCollection = useState('1');
    return WatchScaffold(
      rightAction: CollectionSelectorButton(
        collections: const [
          (uid: '1', color: Colors.red, name: 'Test 1'),
          (uid: '2', color: Colors.green, name: 'Test 2'),
          (uid: '3', color: Colors.blue, name: 'Test 3'),
          (uid: '4', color: Colors.yellow, name: 'Test 4'),
          (uid: '5', color: Colors.cyan, name: 'Test 5'),
          (uid: '6', color: Colors.pink, name: 'Test 6'),
          (uid: '7', color: Colors.purple, name: 'Test 7'),
          (uid: '8', color: Colors.orange, name: 'Test 8'),
          (uid: '9', color: Colors.teal, name: 'Test 9'),
          (uid: '10', color: Colors.lime, name: 'Test 10'),
          (uid: '11', color: Colors.indigo, name: 'Test 11'),
        ],
        currentCollection: currentCollection.value,
        onCollectionSelected: (uid) => currentCollection.value = uid,
      ),
      bottomAction: Hero(
        tag: createButtonHeroTag,
        child: FilledButton(
          child: const Icon(Icons.add),
          onPressed: () {},
        ),
      ),
      body: const SafeArea(
        child: Column(),
      ),
    );
  }
}

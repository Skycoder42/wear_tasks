import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/localization/error_localizer.dart';
import '../../../common/widgets/error_snack_bar.dart';
import '../../widgets/watch_scaffold.dart';
import 'collection_infos.dart';
import 'collection_selector_button.dart';

class CreateTaskPage extends HookConsumerWidget {
  static const createButtonHeroTag = 'CreateTaskPage.createButtonHero';

  const CreateTaskPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionInfos = ref.watch(collectionInfosProvider);

    ref.listen(
      collectionInfosProvider.select((value) => value.error),
      (_, error) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            ErrorSnackBar(
              context: context,
              content: Text(ref.read(errorLocalizerProvider).localize(error)),
            ),
          );
        }
      },
    );

    final currentCollection = useState('1'); // TODO load from settings
    return WatchScaffold(
      loadingOverlayActive: collectionInfos.isLoading,
      rightAction: collectionInfos.hasValue
          ? CollectionSelectorButton(
              collections: collectionInfos.requireValue,
              currentCollection: currentCollection.value,
              onCollectionSelected: (uid) => currentCollection.value = uid,
            )
          : null,
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

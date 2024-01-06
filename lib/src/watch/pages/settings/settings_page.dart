import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/localization/localization.dart';
import '../../widgets/hooks/change_notifier_hook.dart';
import '../../widgets/watch_dialog.dart';
import '../../widgets/watch_scaffold.dart';
import '../create_task/collection_selection/active_collection.dart';
import '../create_task/collection_selection/collection_infos.dart';
import '../create_task/collection_selection/collection_selector_button.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionInfos = ref.watch(collectionInfosProvider);
    final activeCollection = ref.watch(activeCollectionProvider);

    final activeInfo = useMemoized(
      () {
        final infos = collectionInfos.valueOrNull;
        if (infos == null) {
          return null;
        }
        final activeId = activeCollection.valueOrNull;
        if (activeId == null) {
          return null;
        }
        return infos.singleWhereOrNull((i) => i.uid == activeId);
      },
      [collectionInfos, activeCollection],
    );

    final buttonNotifier = useChangeNotifier();

    return WatchScaffold(
      horizontalSafeArea: true,
      loadingOverlayActive:
          collectionInfos.isLoading || activeCollection.isLoading,
      body: ListView(
        children: [
          if (collectionInfos.hasValue && activeCollection.hasValue)
            ListTile(
              leading: CollectionSelectorButton(
                collections: collectionInfos.requireValue,
                currentCollection: activeCollection.requireValue,
                onCollectionSelected: (uid) async => ref
                    .read(activeCollectionProvider.notifier)
                    .setActive(uid, asDefault: true),
                externalOverlayTrigger: buttonNotifier,
                animationAlignment: Alignment.centerLeft,
              ),
              title: Text(
                context.strings.settings_page_default_collection,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                activeInfo?.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: buttonNotifier.notifyListeners,
            ),
          // TODO add expressions configuration here?
        ],
      ),
    );
  }
}

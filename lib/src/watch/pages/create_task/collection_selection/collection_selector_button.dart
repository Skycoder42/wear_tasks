import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/watch_theme.dart';
import '../../../widgets/hooks/change_notifier_hook.dart';
import '../../../widgets/side_button.dart';
import 'collection_infos.dart';
import 'collection_selector_list.dart';

typedef CollectionSelectedCallback = void Function(String uid);

class CollectionSelectorButton extends HookConsumerWidget {
  final List<CollectionInfo> collections;
  final String currentCollection;
  final CollectionSelectedCallback onCollectionSelected;
  final Listenable? externalOverlayTrigger;

  CollectionSelectorButton({
    super.key,
    required this.collections,
    required this.currentCollection,
    required this.onCollectionSelected,
    this.externalOverlayTrigger,
  }) {
    if (collections.isEmpty) {
      throw ArgumentError.value(
        collections,
        'collections',
        'must not be empty',
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCollection = useMemoized(
      () =>
          collections.singleWhereOrNull((c) => c.uid == currentCollection) ??
          collections.first,
      [collections, currentCollection],
    );

    final overlayRef = useState<OverlayEntry?>(null);
    useEffect(
      () {
        if (overlayRef.value case final OverlayEntry entry) {
          return () => _disposeOverlay(entry);
        } else {
          return null;
        }
      },
      [overlayRef.value],
    );

    final triggerOverlay = useCallback(
      () => _showOverlay(context, ref, overlayRef),
      [context, ref, overlayRef],
    );

    useListenableCallback(externalOverlayTrigger, triggerOverlay);

    final theme = ref.watch(
      watchThemeProvider(activeCollection.color ?? WatchTheme.appColor),
    );

    return PopScope(
      canPop: overlayRef.value == null,
      onPopInvoked: (_) => overlayRef.value = null,
      child: Theme(
        data: theme,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SideButton(
            filled: true,
            icon: const Icon(Icons.list),
            onPressed: triggerOverlay,
          ),
        ),
      ),
    );
  }

  void _showOverlay(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<OverlayEntry?> overlayRef,
  ) {
    overlayRef.value = OverlayEntry(
      builder: (context) => Stack(
        children: [
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withOpacity(0.5),
          ),
          CollectionSelectorList(
            collections: collections,
            currentUid: currentCollection,
            onSelected: (uid) {
              overlayRef.value = null;
              onCollectionSelected(uid);
            },
          ),
        ],
      ),
    );
    Overlay.of(context).insert(overlayRef.value!);
  }

  void _disposeOverlay(OverlayEntry entry) {
    if (entry.mounted) {
      entry.remove();
    }
    entry.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<CollectionInfo>('collections', collections))
      ..add(StringProperty('currentCollection', currentCollection))
      ..add(
        ObjectFlagProperty<CollectionSelectedCallback>.has(
          'onCollectionSelected',
          onCollectionSelected,
        ),
      )
      ..add(
        ObjectFlagProperty.has(
          'externalOverlayTrigger',
          externalOverlayTrigger,
        ),
      );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/watch_theme.dart';
import '../../widgets/side_button.dart';

typedef CollectionInfo = ({
  String uid,
  Color color,
  String name,
});

typedef CollectionSelectedCallback = void Function(String uid);

class CollectionSelectorButton extends HookConsumerWidget {
  final List<CollectionInfo> collections;
  final String currentCollection;
  final CollectionSelectedCallback onCollectionSelected;

  const CollectionSelectorButton({
    super.key,
    required this.collections,
    required this.currentCollection,
    required this.onCollectionSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCollection = useMemoized(
      () => collections.singleWhere((c) => c.uid == currentCollection),
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

    final theme = ref.watch(watchThemeProvider(activeCollection.color));

    return Theme(
      data: theme,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SideButton(
          filled: true,
          icon: const Icon(Icons.list),
          onPressed: () => _showOverlay(context, ref, overlayRef),
        ),
      ),
    );
  }

  void _showOverlay(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<OverlayEntry?> overlayRef,
  ) {
    final index = collections.indexWhere((c) => c.uid == currentCollection);
    final controller = ScrollController(initialScrollOffset: 40.0 * index);
    overlayRef.value = OverlayEntry(
      builder: (context) => ListWheelScrollView(
        controller: controller,
        itemExtent: 40,
        // offAxisFraction: -1,
        diameterRatio: 1.25,
        perspective: 0.004,
        children: [
          for (final collection in collections)
            Theme(
              data: ref.watch(watchThemeProvider(collection.color)),
              child: FilledButton.icon(
                onPressed: () {
                  overlayRef.value = null;
                  onCollectionSelected(collection.uid);
                },
                icon: const Icon(Icons.list),
                label: Text(collection.name),
              ),
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
      );
  }
}

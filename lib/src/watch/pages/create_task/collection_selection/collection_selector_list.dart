import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/watch_theme.dart';
import 'collection_infos.dart';
import 'collection_selector_button.dart';

class CollectionSelectorList extends HookConsumerWidget {
  static const _itemExtend = 40.0;
  static const _animationDuration = Duration(milliseconds: 100);

  final List<CollectionInfo> collections;
  final String currentUid;
  final CollectionSelectedCallback onSelected;

  const CollectionSelectorList({
    super.key,
    required this.collections,
    required this.currentUid,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = collections.indexWhere((c) => c.uid == currentUid);
    final scrollController = useScrollController(
      initialScrollOffset: _itemExtend * index,
    );
    final animationController = useAnimationController();

    return ListWheelScrollView(
      controller: scrollController,
      itemExtent: _itemExtend,
      // offAxisFraction: -1,
      diameterRatio: 1.25,
      perspective: 0.004,
      children: [
        for (final collection in collections)
          Theme(
            data: ref.watch(
              watchThemeProvider(collection.color ?? WatchTheme.appColor),
            ),
            child: FilledButton.icon(
              onPressed: () async {
                await animationController.reverse();
                onSelected(collection.uid);
              },
              icon: const Icon(Icons.list),
              label: Text(collection.name ?? collection.uid),
            ),
          ),
      ],
    )
        .animate(controller: animationController)
        .fade(duration: _animationDuration)
        .scale(alignment: Alignment.centerRight, duration: _animationDuration);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<CollectionInfo>('collections', collections))
      ..add(StringProperty('initialCollectionUid', currentUid))
      ..add(
        ObjectFlagProperty<CollectionSelectedCallback>.has(
          'onSelected',
          onSelected,
        ),
      );
  }
}

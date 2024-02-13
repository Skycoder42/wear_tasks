import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/extensions/core_extensions.dart';
import '../../../common/localization/localization.dart';
import '../../app/router/watch_router.dart';
import '../../models/task.dart';
import '../../widgets/hooks/change_notifier_hook.dart';
import '../../widgets/hooks/rotary_scroll_controller_hook.dart';
import '../../widgets/watch_scaffold.dart';
import '../create_task/collection_selection/collection_selector_button.dart';
import '../date_time_picker/date_time_picker_page.dart';
import 'settings_controller.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsControllerProvider);
    final buttonNotifier = useChangeNotifier();
    final scrollController = useRotaryScrollController(ref);

    return WatchScaffold(
      horizontalSafeArea: true,
      loadingOverlayActive: settingsState.isLoading,
      body: settingsState.hasValue
          ? _buildBody(
              context,
              ref,
              settingsState.requireValue,
              buttonNotifier,
              scrollController,
            )
          : const SizedBox(),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
    HookChangeNotifier buttonNotifier,
    ScrollController scrollController,
  ) =>
      ListView(
        controller: scrollController,
        children: [
          ListTile(
            leading: const Icon(Icons.watch_later),
            title: Text(context.strings.settings_page_default_time),
            subtitle: Text(settings.defaultTime.format(context)),
            onTap: () async {
              final newDateTime = await DateTimePickerRoute(
                settings.defaultTime.toDateTime(),
                mode: DateTimePickerMode.timeOnly,
              ).push<DateTime>(context);
              if (newDateTime != null) {
                await ref
                    .read(settingsControllerProvider.notifier)
                    .updateDefaultTime(TimeOfDay.fromDateTime(newDateTime));
              }
            },
          ),
          ListTile(
            iconColor: settings.defaultCollectionInfo.color,
            leading: const Icon(Icons.list),
            title: Text(
              context.strings.settings_page_default_collection,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              settings.defaultCollectionInfo.name ??
                  settings.defaultCollectionInfo.uid,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: buttonNotifier.notifyListeners,
          ),
          ListTile(
            leading: settings.defaultPriority.icon,
            title: Text(context.strings.settings_page_default_priority),
            subtitle: Text(
              context.strings
                  .settings_page_priority(settings.defaultPriority.name),
            ),
            onTap: () async {
              var nextIndex = settings.defaultPriority.index + 1;
              if (nextIndex >= TaskPriority.values.length) {
                nextIndex = 0;
              }
              await ref
                  .read(settingsControllerProvider.notifier)
                  .updateDefaultPriority(TaskPriority.values[nextIndex]);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(context.strings.settings_page_logout),
            onTap: () async => const LogoutRoute().push(context),
          ),
          // TODO add expressions configuration here?
          Offstage(
            child: CollectionSelectorButton(
              collections: settings.collectionInfos,
              currentCollection: settings.defaultCollection,
              onCollectionSelected: (uid) async => ref
                  .read(settingsControllerProvider.notifier)
                  .updateDefaultCollection(uid),
              externalOverlayTrigger: buttonNotifier,
              animationAlignment: Alignment.centerLeft,
            ),
          ),
        ],
      );
}

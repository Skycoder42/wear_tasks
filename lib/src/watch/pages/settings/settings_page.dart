import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/extensions/core_extensions.dart';
import '../../../common/localization/localization.dart';
import '../../app/router/watch_router.dart';
import '../../widgets/hooks/change_notifier_hook.dart';
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

    return WatchScaffold(
      horizontalSafeArea: true,
      loadingOverlayActive: settingsState.isLoading,
      body: settingsState.hasValue
          ? _buildBody(context, ref, settingsState.requireValue, buttonNotifier)
          : const SizedBox(),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
    HookChangeNotifier buttonNotifier,
  ) =>
      ListView(
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
            iconColor: settings.activeCollectionInfo.color,
            leading: const Icon(Icons.list),
            title: Text(
              context.strings.settings_page_default_collection,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              settings.activeCollectionInfo.name ??
                  settings.activeCollectionInfo.uid,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: buttonNotifier.notifyListeners,
          ),
          // TODO add expressions configuration here?
          Offstage(
            child: CollectionSelectorButton(
              collections: settings.collectionInfos,
              currentCollection: settings.activeCollectionUid,
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

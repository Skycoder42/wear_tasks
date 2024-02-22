import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/localization/localization.dart';
import '../../app/watch_provider_scope.dart';
import '../../services/account_service.dart';
import '../../widgets/hooks/rotary_scroll_controller_hook.dart';
import '../../widgets/watch_dialog.dart';

class LogoutPage extends HookConsumerWidget {
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final scrollController = useRotaryScrollController();

    return WatchDialog<void>(
      horizontalSafeArea: true,
      loadingOverlayActive: isLoading.value,
      onAccept: () async {
        isLoading.value = true;
        final scope = WatchProviderScope.of(context);
        await ref.read(accountServiceProvider.notifier).logout();
        scope.resetApp();
      },
      body: SingleChildScrollView(
        controller: scrollController,
        child: SafeArea(
          child: Text(context.strings.logout_dialog_message),
        ),
      ),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../common/localization/localization.dart';
import 'watch_router.dart';
import 'watch_theme.dart';

class WatchApp extends ConsumerWidget {
  const WatchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        // router config
        routerConfig: ref.watch(watchRouterProvider),
        restorationScopeId: 'watch-app',

        // localization
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateTitle: (context) => context.strings.app_name,

        // theming
        color: WatchTheme.seedColor,
        theme: WatchTheme.theme,
        themeMode: ThemeMode.dark,

        // app configuration
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          final diameter = min(mediaQuery.size.width, mediaQuery.size.height);
          final padding = (diameter - ((diameter / 2) * sqrt2)) / 2;
          return MediaQuery(
            data: mediaQuery.copyWith(
              padding: EdgeInsets.all(padding),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      );
}

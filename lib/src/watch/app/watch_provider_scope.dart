import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../common/localization/localization.dart';

class WatchProviderScope extends StatefulWidget {
  final Widget child;

  const WatchProviderScope({
    super.key,
    required this.child,
  });

  @override
  State<WatchProviderScope> createState() => WatchProviderScopeState();

  static WatchProviderScopeState of(BuildContext context) =>
      context.findAncestorStateOfType<WatchProviderScopeState>()!;
}

class WatchProviderScopeState extends State<WatchProviderScope> {
  late GlobalKey _scopeKey;
  AppLocalizations? _localizations;

  @override
  void initState() {
    super.initState();
    _scopeKey = GlobalKey();
  }

  @override
  Widget build(BuildContext context) => ProviderScope(
        key: _scopeKey,
        overrides: [
          if (_localizations != null)
            appLocalizationsProvider.overrideWith((_) => _localizations!)
          else
            appLocalizationsProvider,
        ],
        child: widget.child,
      );

  void updateLocalizations(AppLocalizations localizations) => scheduleMicrotask(
        () => setState(() {
          _localizations = localizations;
        }),
      );

  void resetApp() => scheduleMicrotask(
        () => setState(() {
          _scopeKey = GlobalKey();
        }),
      );
}

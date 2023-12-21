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
  State<WatchProviderScope> createState() => _WatchProviderScopeState();

  static void updateLocalizations(BuildContext context) => context
      .findAncestorStateOfType<_WatchProviderScopeState>()
      ?._updateLocalizations(context.strings);
}

class _WatchProviderScopeState extends State<WatchProviderScope> {
  AppLocalizations? _localizations;

  @override
  Widget build(BuildContext context) => ProviderScope(
        overrides: [
          if (_localizations != null)
            appLocalizationsProvider.overrideWithValue(_localizations!)
          else
            appLocalizationsProvider,
        ],
        child: widget.child,
      );

  void _updateLocalizations(AppLocalizations localizations) => setState(() {
        _localizations = localizations;
      });
}

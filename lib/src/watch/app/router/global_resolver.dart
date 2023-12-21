import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/account_service.dart';
import 'watch_router.dart';

part 'global_resolver.g.dart';

@riverpod
GlobalResolver globalResolver(GlobalResolverRef ref) => GlobalResolver(ref);

class GlobalResolver {
  final _logger = Logger('$GlobalResolver');

  final GlobalResolverRef _ref;

  GlobalResolver(this._ref);

  Future<String?> call(BuildContext context, GoRouterState state) async {
    _logger.finer('Begging redirect resolution for ${state.fullPath}');
    if (state.fullPath?.startsWith(const LoginRoute().location) ?? false) {
      _logger.fine('${state.fullPath}: Allowing login route');
      return null;
    }

    try {
      _logger.finer('${state.fullPath}: loading account data...');
      final account = await _ref.read(accountServiceProvider.future);
      _logger.finer('${state.fullPath}: Account data loaded');
      if (account != null) {
        _logger.fine('${state.fullPath}: Logged in, allowing route');
        return null;
      }

      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      _logger.severe('${state.fullPath}: Failed to restore account', e, s);
    }

    _logger.info('${state.fullPath}: Not logged in, redirecting to login page');
    return LoginRoute(redirectTo: state.fullPath).location;
  }
}

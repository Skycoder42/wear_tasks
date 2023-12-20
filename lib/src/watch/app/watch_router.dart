import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../pages/home/home_page.dart';
import '../pages/login/login_page.dart';
import '../services/account_service.dart';

part 'watch_router.g.dart';

@riverpod
GoRouter watchRouter(WatchRouterRef ref) => GoRouter(
      routes: $appRoutes,
      redirect: ref.watch(globalResolverProvider).call,
    );

@riverpod
GlobalResolver globalResolver(GlobalResolverRef ref) => GlobalResolver(ref);

class GlobalResolver {
  final _logger = Logger('$GlobalResolver');

  final GlobalResolverRef _ref;

  GlobalResolver(this._ref);

  Future<String?> call(BuildContext context, GoRouterState state) async {
    if (state.fullPath?.startsWith(const LoginRoute().location) ?? false) {
      _logger.finer('${state.fullPath}: login route');
      return null;
    }

    try {
      _logger.finest('${state.fullPath}: loading account data...');
      final account = await _ref.read(accountServiceProvider.future);
      if (account != null) {
        _logger.finest('${state.fullPath}: account loaded');
        return null;
      }

      _logger.info('${state.fullPath}: No persistent account found');
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      _logger.severe('${state.fullPath}: Failed to restore account', e, s);
    }

    _logger.finer('${state.fullPath}: redirecting to login page');
    return LoginRoute(redirectTo: state.fullPath).location;
  }
}

@TypedGoRoute<HomeRoute>(path: '/')
@immutable
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}

@TypedGoRoute<LoginRoute>(path: '/login')
@immutable
class LoginRoute extends GoRouteData {
  final String? redirectTo;

  const LoginRoute({
    this.redirectTo,
  });

  @override
  Widget build(BuildContext context, GoRouterState state) => LoginPage(
        redirectTo: redirectTo,
      );
}

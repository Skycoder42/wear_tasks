part of '../watch_router.dart';

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

@TypedGoRoute<LogoutRoute>(path: '/logout')
@immutable
class LogoutRoute extends GoRouteData {
  const LogoutRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const LogoutPage();
}

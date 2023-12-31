part of '../watch_router.dart';

@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: [
    TypedGoRoute<CreateTaskRoute>(path: 'tasks/create'),
  ],
)
@immutable
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}

@immutable
class CreateTaskRoute extends GoRouteData {
  const CreateTaskRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateTaskPage();
}

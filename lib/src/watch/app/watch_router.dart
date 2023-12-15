import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../widgets/watch_scaffold.dart';

part 'watch_router.g.dart';

@riverpod
GoRouter watchRouter(WatchRouterRef ref) => GoRouter(routes: $appRoutes);

@TypedGoRoute<HomeRoute>(path: '/')
@immutable
class HomeRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const WatchScaffold(body: Placeholder());
}

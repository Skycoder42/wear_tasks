import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../models/task_recurrence.dart';
import '../../pages/create_task/create_task_page.dart';
import '../../pages/date_time_picker/date_time_picker_page.dart';
import '../../pages/home/home_page.dart';
import '../../pages/login/login_page.dart';
import '../../pages/login/logout_page.dart';
import '../../pages/settings/settings_page.dart';
import '../../pages/task_due_selection/recurrence_picker_page.dart';
import '../../pages/task_due_selection/task_due_selection_page.dart';
import 'global_resolver.dart';
import 'startup_observer.dart';

part 'routes/app_routes.dart';
part 'routes/login_routes.dart';
part 'routes/selection_routes.dart';
part 'watch_router.g.dart';

@riverpod
GoRouter watchRouter(WatchRouterRef ref) => GoRouter(
      routes: $appRoutes,
      observers: [
        ref.watch(startupObserverProvider),
        SentryNavigatorObserver(),
      ],
      redirect: ref.watch(globalResolverProvider).call,
    );

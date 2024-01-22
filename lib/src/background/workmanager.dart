// ignore_for_file: unreachable_from_main

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workmanager/workmanager.dart';

import '../common/setup.dart';
import 'tasks/task_manager.dart';

part 'workmanager.g.dart';

@Riverpod(keepAlive: true)
Future<Workmanager> workmanager(WorkmanagerRef ref) async {
  final wm = Workmanager();
  await wm.initialize(
    workmanagerMain,
    isInDebugMode: kDebugMode,
  );
  return wm;
}

@pragma('vm:entry-point')
Future<void> workmanagerMain() async {
  setup();

  final workmanager = Workmanager();
  final container = ProviderContainer(
    overrides: [
      workmanagerProvider.overrideWith((ref) => workmanager),
    ],
  );

  final taskManager = await container.read(taskManagerProvider.future);
  workmanager.executeTask(taskManager.call);
}

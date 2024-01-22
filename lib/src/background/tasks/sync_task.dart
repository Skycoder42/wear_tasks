import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../watch/services/retry_uploads_service.dart';
import 'workmanager_task.dart';

final class SyncTask extends WorkmanagerTask {
  static const taskName = 'sync';

  const SyncTask() : super.noData();

  @override
  Future<bool> execute(Ref ref, void data) async {
    final logger = Logger('SyncTask');

    try {
      await ref.read(retryUploadsServiceProvider.notifier).uploadPending();
      return switch (await ref.read(retryUploadsServiceProvider.future)) {
        AllUploadedRetryState() => true,
        _ => false,
      };
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      logger.shout('SyncTask failed with critical error', e, s);
      return false;
    }
  }
}

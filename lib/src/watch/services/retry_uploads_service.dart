import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/collection_repository.dart';
import '../repositories/item_repository.dart';

part 'retry_uploads_service.freezed.dart';
part 'retry_uploads_service.g.dart';

@freezed
class RetryUploadsState with _$RetryUploadsState {
  const factory RetryUploadsState.allUploaded() = AllUploadedRetryState;
  const factory RetryUploadsState.hasPending() = HasPendingUploadsRetryState;
  const factory RetryUploadsState.uploading() = UploadingRetryState;
}

@riverpod
class RetryUploadsService extends _$RetryUploadsService {
  @override
  Future<RetryUploadsState> build() async {
    final collectionRepository =
        await ref.watch(collectionRepositoryProvider.future);
    var hasPending = await collectionRepository.hasPendingUploads();

    await for (final uid in collectionRepository.listAll()) {
      final itemRepository =
          await ref.watch(itemRepositoryProvider(uid).future);
      hasPending = hasPending || itemRepository.hasPendingUploads();
    }

    return hasPending
        ? const RetryUploadsState.hasPending()
        : const RetryUploadsState.allUploaded();
  }

  Future<void> uploadPending() async {
    switch (await future) {
      case AllUploadedRetryState():
      case UploadingRetryState():
        return;
      default:
        break;
    }

    state = const AsyncValue.data(RetryUploadsState.uploading());
    try {
      final collectionRepository =
          await ref.read(collectionRepositoryProvider.future);
      await collectionRepository.retryPendingUploads();

      await for (final uid in collectionRepository.listAll()) {
        final itemRepository =
            await ref.watch(itemRepositoryProvider(uid).future);
        await itemRepository.retryPendingUploads();
      }

      ref.invalidateSelf();

      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}

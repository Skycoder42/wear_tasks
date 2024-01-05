import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../repositories/collection_repository.dart';
import '../../repositories/item_repository.dart';

part 'retry_uploads_service.freezed.dart';
part 'retry_uploads_service.g.dart';

@freezed
class RetryUploadsState with _$RetryUploadsState {
  const factory RetryUploadsState.allUploaded() = AllUploadedRetryState;
  const factory RetryUploadsState.hasPending() = HasPendingUploadsRetryState;
  const factory RetryUploadsState.uploading() = UploadingRetryState;
  const factory RetryUploadsState.uploadFailed(Object error) =
      UploadFailedRetryState;
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
    switch (future) {
      case AllUploadedRetryState():
      case UploadingRetryState():
        return;
      default:
        break;
    }

    state = const AsyncData(RetryUploadsState.uploading());

    final collectionRepository =
        await ref.read(collectionRepositoryProvider.future);

    // TODO here
  }
}

import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:logging/logging.dart';

import '../etebase/auto_disposable.dart';
import '../storage/collection_storage.dart';

class CollectionRepository {
  final EtebaseCollectionManager collectionManager;
  final CollectionStorage collectionStorage;
  final _logger = Logger('CollectionRepository');

  final _collections = <String, _CollectionRef>{};
  String? _stoken;

  CollectionRepository({
    required this.collectionManager,
    required this.collectionStorage,
  });

  Stream<String> list(String collectionType) async* {}

  Stream<String> listMulti(List<String> collectionTypes) async* {}

  Stream<String> _list() async* {
    yield* Stream.fromIterable(_collections.keys);
  }

  Stream<String> _listRemote(_ListFn listFn) async* {
    var isDone = false;
    do {
      var needsDispose = true;
      final response = await listFn(
        EtebaseFetchOptions(stoken: _stoken),
      );

      try {
        final items = await _refList(response);
        needsDispose = false;

        for (final item in items) {
          final uid = await item.instance.getUid();
          final deleted = await item.instance.isDeleted();
          if (deleted) {
            await _removeCache(uid);
          } else if (await _updateCache(uid, item)) {
            yield uid;
          }
        }

        for (final item in await response.getRemovedMemberships()) {
          final uid = await item.getUid();
          await _removeCache(uid);
        }

        _stoken = await response.getStoken();
        isDone = await response.isDone();
      } finally {
        if (needsDispose) {
          await response.dispose();
        }
      }
    } while (!isDone);
  }

  Future<List<_CollectionRef>> _refList(
    EtebaseCollectionListResponse response,
  ) async =>
      _CollectionRef.list(
        response,
        (i) => i.dispose(),
        await response.getData(),
      );
}

typedef _ListFn = Future<EtebaseCollectionListResponse> Function(
  EtebaseFetchOptions? fetchOptions,
);

typedef _CollectionRef = AutoDisposable<EtebaseCollection>;

import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:logging/logging.dart';

import '../etebase/auto_disposable.dart';
import '../storage/collection_storage.dart';

class CollectionCache {
  final CollectionStorage collectionStorage;
  final _logger = Logger('CollectionCache');

  final _collections = <String, _CollectionRef>{};

  CollectionCache({
    required this.collectionStorage,
  });

  Future<bool> update(
    _CollectionRef collection, {
    String? uidHint,
  }) async {}
}

typedef _CollectionRef = AutoDisposable<EtebaseCollection>;

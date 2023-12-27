import 'dart:ui';

import 'package:etebase_flutter/etebase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/localization/localization.dart';
import '../../../common/providers/package_info_provider.dart';
import '../../../common/utils/hex_color.dart';
import '../../app/watch_theme.dart';
import '../../repositories/collection_repository.dart';

part 'collection_infos.g.dart';

typedef CollectionInfo = ({
  String uid,
  String? name,
  Color? color,
});

@riverpod
class CollectionInfos extends _$CollectionInfos {
  @override
  Future<List<CollectionInfo>> build() async {
    final repository = await ref.watch(collectionRepositoryProvider.future);
    final infos = await _loadInfos(repository).toList();

    if (infos.isEmpty) {
      return [
        await _createDefaultCollection(repository),
      ];
    }

    return infos;
  }

  Stream<CollectionInfo> _loadInfos(CollectionRepository repository) async* {
    await for (final uid in repository.listAll()) {
      final metadata = await repository.getMeta(uid);
      yield _createInfo(uid, metadata);
    }
  }

  Future<CollectionInfo> _createDefaultCollection(
    CollectionRepository repository,
  ) async {
    final packageInfo = await ref.read(packageInfoProvider.future);
    final strings = ref.read(appLocalizationsProvider);
    final metadata = EtebaseItemMetadata(
      name: strings.default_collection_name,
      description: strings.default_collection_description(
        packageInfo.appName,
        packageInfo.version,
      ),
      color: WatchTheme.appColor.toHexString(),
      mtime: DateTime.now(),
    );
    final uid = await repository.create(metadata);
    return _createInfo(uid, metadata);
  }

  CollectionInfo _createInfo(String uid, EtebaseItemMetadata metadata) => (
        uid: uid,
        name: metadata.name,
        color: metadata.color != null ? HexColor.parse(metadata.color!) : null,
      );
}

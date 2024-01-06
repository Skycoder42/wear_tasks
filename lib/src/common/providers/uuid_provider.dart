import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/data.dart';
import 'package:uuid/rng.dart';
import 'package:uuid/uuid.dart';

part 'uuid_provider.g.dart';

@Riverpod(keepAlive: true)
Uuid uuid(UuidRef ref) => Uuid(
      goptions: GlobalOptions(CryptoRNG()),
    );

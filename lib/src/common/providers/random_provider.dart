import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'random_provider.g.dart';

@Riverpod(keepAlive: true)
Random random(RandomRef ref) => Random.secure();

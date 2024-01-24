import 'package:drift/drift.dart';

part 'database.g.dart';

@DriftDatabase(
  include: {'database.drift'},
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}

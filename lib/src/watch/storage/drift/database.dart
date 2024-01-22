import 'package:drift/drift.dart';

part 'database.g.dart';

class StoredCollection extends Table {
  TextColumn get id => text().unique()();
  BlobColumn get data => blob()();
  BoolColumn get pendingUpload =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get isStrict => true;
}

class StoredItem extends Table {
  TextColumn get id => text().unique()();
  BlobColumn get data => blob()();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get isStrict => true;
}

@DriftDatabase(tables: [StoredCollection, StoredItem])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}

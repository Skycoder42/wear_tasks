import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../watch/repositories/settings.dart';
import '../../watch/storage/drift/database.dart';
import 'random_provider.dart';

part 'app_database_provider.g.dart';

@Riverpod(keepAlive: true)
Future<AppDatabase> appDatabase(AppDatabaseRef ref) async {
  final passphrase = await _getDatabasePassphrase(ref);
  final database = await _openDatabase(passphrase);
  return AppDatabase(database);
}

Future<String> _getDatabasePassphrase(AppDatabaseRef ref) async {
  final settings = await ref.watch(settingsProvider.future);
  if (settings.sql.hasCipherPassphrase) {
    return settings.sql.cipherPassphrase!;
  } else {
    final random = ref.read(randomProvider);
    final randomBytes = List.generate(128, (index) => random.nextInt(255));
    final passphrase = base64.encode(randomBytes);
    await settings.sql.setCipherPassphrase(passphrase);
    return passphrase;
  }
}

Future<QueryExecutor> _openDatabase(String passphrase) async {
  // must be done here as method channels are not available in the isolate
  await _setupSqlite();

  final dbFolder = await getApplicationSupportDirectory();
  final file = File.fromUri(dbFolder.uri.resolve('storage.db'));

  return NativeDatabase.createInBackground(
    file,
    isolateSetup: _setupIsolate,
    setup: (db) => _setupDatabase(db, passphrase),
    logStatements: kDebugMode,
  );
}

void _setupIsolate() {
  open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
}

Future<void> _setupSqlite() async {
  _setupIsolate();
  await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
  sqlite3.tempDirectory = (await getTemporaryDirectory()).path;
}

void _setupDatabase(Database database, String passphrase) {
  assert(_debugCheckSqlCipher(database), 'SQLCipher is not available!');

  database.execute("PRAGMA key = '$passphrase';");
}

bool _debugCheckSqlCipher(Database database) {
  final versionResult = database.select('PRAGMA cipher_version;');
  if (versionResult.isEmpty) {
    return false;
  }
  // ignore: avoid_print
  print('SQLCipher version: ${versionResult.first}');
  return true;
}

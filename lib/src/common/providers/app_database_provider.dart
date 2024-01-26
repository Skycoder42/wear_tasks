import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:logging/logging.dart';
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
  await _setupSqlite();
  final passphrase = await _getDatabasePassphrase(ref);
  final database = await _openDatabase(passphrase);
  return AppDatabase(database);
}

Future<void> _setupSqlite() async {
  sqlite3.tempDirectory = (await getTemporaryDirectory()).path;
  open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
  await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
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
  final logger = Logger('$AppDatabase');

  final dbFolder = await getApplicationSupportDirectory();
  final file = File.fromUri(dbFolder.uri.resolve('storage.db'));
  final database = NativeDatabase.createInBackground(file);

  final versionResult =
      await database.runSelect('PRAGMA cipher_version;', const []);
  if (versionResult.isEmpty) {
    throw StateError(
      'SQLCipher library is not available, please check your dependencies!',
    );
  }
  logger.info('SQLCipher version: ${versionResult.first}');

  await database.runCustom('PRAGMA key = ?;', [passphrase]);

  return database;
}

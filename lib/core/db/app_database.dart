// Design Ref: §3.3 — Drift + SQLCipher encrypted database.
// The DB file is fully encrypted; the raw 256-bit key is loaded from
// CryptoPort (Keystore-backed) and applied via `PRAGMA key`.
//
// Codegen: run `dart run build_runner build --delete-conflicting-outputs`
// to produce app_database.g.dart.

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';

import '../domain/crypto_port.dart';

part 'app_database.g.dart';

@DataClassName('TokenEntryRow')
class TokenEntries extends Table {
  TextColumn get id => text()();
  TextColumn get serviceName => text().named('service_name')();
  TextColumn get url => text().withDefault(const Constant(''))();
  IntColumn get issuedAt => integer().named('issued_at').nullable()();
  IntColumn get expiresAt => integer().named('expires_at').nullable()();
  TextColumn get note => text().withDefault(const Constant(''))();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
  IntColumn get deletedAt => integer().named('deleted_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [TokenEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase(CryptoPort crypto) : super(_openConnection(crypto));

  /// For tests: inject an in-memory / custom executor.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_expires_at '
            'ON token_entries(expires_at)',
          );
        },
        onUpgrade: (m, from, to) async {
          // v2: add url column.
          if (from < 2) {
            await m.addColumn(tokenEntries, tokenEntries.url);
          }
          // v3: add deleted_at tombstone column.
          if (from < 3) {
            await m.addColumn(tokenEntries, tokenEntries.deletedAt);
          }
        },
      );
}

LazyDatabase _openConnection(CryptoPort crypto) {
  return LazyDatabase(() async {
    if (Platform.isAndroid) {
      // Ensures SQLCipher's libsqlcipher is used instead of system sqlite.
      await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
      open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'tokens.db.enc'));
    final keyHex = await crypto.loadOrCreateDbKey();

    return NativeDatabase(
      file,
      setup: (raw) {
        // Raw 256-bit key (no extra KDF) per SQLCipher raw-key syntax.
        raw.execute('PRAGMA key = "x\'$keyHex\'"');
        raw.execute('PRAGMA cipher_memory_security = ON');

        // Fail fast if the binary is plain SQLite (no cipher support).
        final res = raw.select('PRAGMA cipher_version');
        if (res.isEmpty || (res.first.values.first?.toString().isEmpty ?? true)) {
          throw StateError(
            'SQLCipher not active — check sqlcipher_flutter_libs setup',
          );
        }
      },
    );
  });
}

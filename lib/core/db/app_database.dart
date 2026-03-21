import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/riwaya_table.dart';
import 'tables/surah_table.dart';
import 'tables/page_ayah_index_table.dart';
import 'tables/glyph_table.dart';
import 'tables/bookmark_table.dart';
import 'tables/reading_session_table.dart';
import 'daos/glyph_dao.dart';
import 'daos/bookmark_dao.dart';
import 'daos/reading_session_dao.dart';
import 'daos/surah_dao.dart';
import 'daos/riwaya_dao.dart';
import 'daos/page_ayah_index_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    RiwayaTable,
    SurahTable,
    PageAyahIndexTable,
    GlyphTable,
    BookmarkTable,
    ReadingSessionTable,
  ],
  daos: [
    GlyphDao,
    BookmarkDao,
    ReadingSessionDao,
    SurahDao,
    RiwayaDao,
    PageAyahIndexDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'quran_mushaf_v3');
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedRiwayas();
        },
        onUpgrade: (m, from, to) async {
          // Dev: drop and recreate on schema change.
          for (final table in allTables) {
            await m.deleteTable(table.actualTableName);
          }
          await m.createAll();
          await _seedRiwayas();
        },
      );

  Future<void> _seedRiwayas() async {
    await batch((b) {
      b.insertAll(riwayaTable, [
        RiwayaTableCompanion.insert(
          key: 'qaloun',
          displayName: 'قالون عن نافع',
          isBundled: const Value(true),
          isDownloaded: const Value(true),
          downloadedAt: Value(DateTime.now()),
          imageNativeWidth: const Value(1110),
        ),
        RiwayaTableCompanion.insert(
          key: 'warsh',
          displayName: 'ورش عن نافع',
          imageNativeWidth: const Value(2268),
        ),
        RiwayaTableCompanion.insert(
          key: 'hafs',
          displayName: 'حفص عن عاصم',
          imageNativeWidth: const Value(2268),
        ),
      ]);
    });
  }
}

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'tables/riwaya_table.dart';
import 'tables/surah_table.dart';
import 'tables/page_ayah_index_table.dart';
import 'tables/glyph_table.dart';
import 'tables/bookmark_table.dart';
import 'tables/reading_session_table.dart';
import 'tables/ayah_text_table.dart';
import 'tables/khatmah_table.dart';
import 'tables/khatmah_day_table.dart';
import 'daos/glyph_dao.dart';
import 'daos/bookmark_dao.dart';
import 'daos/reading_session_dao.dart';
import 'daos/surah_dao.dart';
import 'daos/riwaya_dao.dart';
import 'daos/page_ayah_index_dao.dart';
import 'daos/ayah_text_dao.dart';
import 'daos/khatmah_dao.dart';
// Re-export normalizeArabic so it's available for seeding.
export 'daos/ayah_text_dao.dart' show normalizeArabic;

part 'app_database.g.dart';

/// Qaloun surah start pages (1-indexed). Index 0 = surah 1.
const _qalounSurahStartPages = [
  1,
  2,
  50,
  77,
  106,
  128,
  151,
  177,
  187,
  208,
  221,
  235,
  249,
  255,
  262,
  267,
  282,
  293,
  305,
  312,
  322,
  332,
  342,
  350,
  359,
  367,
  377,
  385,
  396,
  404,
  411,
  415,
  418,
  428,
  434,
  440,
  446,
  453,
  458,
  467,
  477,
  483,
  489,
  496,
  499,
  502,
  507,
  511,
  515,
  518,
  520,
  523,
  526,
  528,
  531,
  534,
  537,
  542,
  545,
  549,
  551,
  553,
  554,
  556,
  558,
  560,
  562,
  564,
  566,
  568,
  570,
  572,
  574,
  575,
  577,
  578,
  580,
  582,
  583,
  585,
  586,
  587,
  587,
  589,
  590,
  591,
  591,
  592,
  593,
  594,
  595,
  595,
  596,
  596,
  597,
  597,
  598,
  598,
  599,
  599,
  600,
  600,
  601,
  601,
  601,
  602,
  602,
  602,
  603,
  603,
  603,
  604,
  604,
  604,
];

@DriftDatabase(
  tables: [
    RiwayaTable,
    SurahTable,
    PageAyahIndexTable,
    GlyphTable,
    BookmarkTable,
    ReadingSessionTable,
    AyahTextTable,
    KhatmahTable,
    KhatmahDayTable,
  ],
  daos: [
    GlyphDao,
    BookmarkDao,
    ReadingSessionDao,
    SurahDao,
    RiwayaDao,
    PageAyahIndexDao,
    AyahTextDao,
    KhatmahDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 15;

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
      for (final table in allTables) {
        await m.deleteTable(table.actualTableName);
      }
      await m.createAll();
      await _seedRiwayas();
    },
    beforeOpen: (details) async {
      await _seedSurahsIfNeeded();
      await _seedGlyphsIfNeeded();
      await _seedAyahTextIfNeeded();
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
          imageNativeWidth: const Value(1310),
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

  Future<void> _seedSurahsIfNeeded() async {
    try {
      final existing = await surahDao.getAllSurahs();
      if (existing.isNotEmpty) {
        debugPrint('[SEED] Surahs already seeded (${existing.length})');
        return;
      }

      final jsonStr = await rootBundle.loadString(
        'assets/metadata/surahs.json',
      );
      final List<dynamic> surahList = json.decode(jsonStr);

      await batch((b) {
        b.insertAll(
          surahTable,
          surahList
              .map(
                (s) => SurahTableCompanion.insert(
                  id: Value(s['id'] as int),
                  nameArabic: s['nameArabic'] as String,
                  nameTransliterated: s['nameTransliterated'] as String,
                  ayahCount: s['ayahCount'] as int,
                ),
              )
              .toList(),
        );
      });
      debugPrint('[SEED] Inserted ${surahList.length} surahs');

      // Seed page-to-surah index for Qaloun.
      const riwayaId = 1;
      final rows = <PageAyahIndexTableCompanion>[];
      for (int surah = 1; surah <= 114; surah++) {
        final startPage = _qalounSurahStartPages[surah - 1];
        final endPage = surah < 114 ? _qalounSurahStartPages[surah] - 1 : 604;
        for (int page = startPage; page <= endPage; page++) {
          rows.add(
            PageAyahIndexTableCompanion.insert(
              pageNumber: page,
              surahId: surah,
              ayahNumber: 1,
              riwayaId: riwayaId,
            ),
          );
        }
      }
      await batch((b) => b.insertAll(pageAyahIndexTable, rows));
      debugPrint('[SEED] Inserted ${rows.length} page-ayah-index rows');
    } catch (e) {
      debugPrint('[SEED] ERROR seeding surahs: $e');
    }
  }

  Future<void> _seedGlyphsIfNeeded() async {
    try {
      final existing = await glyphDao.getGlyphsForPage(1, 1);
      if (existing.isNotEmpty) {
        debugPrint('[SEED] Glyphs already seeded');
        return;
      }

      final jsonStr = await rootBundle.loadString(
        'assets/metadata/glyphs_qaloun.json',
      );
      final List<dynamic> glyphs = json.decode(jsonStr);

      const batchSize = 500;
      for (int i = 0; i < glyphs.length; i += batchSize) {
        final chunk = glyphs.skip(i).take(batchSize);
        await batch((b) {
          b.insertAll(
            glyphTable,
            chunk
                .map(
                  (g) => GlyphTableCompanion.insert(
                    pageNumber: g['p'] as int,
                    lineNumber: g['l'] as int,
                    surahId: g['s'] as int,
                    ayahNumber: g['a'] as int,
                    position: g['n'] as int,
                    minX: g['x1'] as int,
                    maxX: g['x2'] as int,
                    minY: g['y1'] as int,
                    maxY: g['y2'] as int,
                    riwayaId: 1,
                  ),
                )
                .toList(),
          );
        });
      }
      debugPrint('[SEED] Inserted ${glyphs.length} glyphs');
    } catch (e) {
      debugPrint('[SEED] ERROR seeding glyphs: $e');
    }
  }

  Future<void> _seedAyahTextIfNeeded() async {
    try {
      final count = await ayahTextDao.count();
      if (count > 0) {
        debugPrint('[SEED] Ayah text already seeded ($count)');
        return;
      }

      final jsonStr = await rootBundle.loadString(
        'assets/metadata/qaloon_ayah_text.json',
      );
      final List<dynamic> ayahs = json.decode(jsonStr);

      const batchSize = 500;
      for (int i = 0; i < ayahs.length; i += batchSize) {
        final chunk = ayahs.skip(i).take(batchSize);
        await batch((b) {
          b.insertAll(
            ayahTextTable,
            chunk
                .map(
                  (a) {
                    final text = a['t'] as String;
                    return AyahTextTableCompanion.insert(
                      surahId: a['s'] as int,
                      ayahNumber: a['a'] as int,
                      pageNumber: a['p'] as int,
                      ayahText: text,
                      textNormalized: Value(normalizeArabic(text)),
                    );
                  },
                )
                .toList(),
          );
        });
      }
      debugPrint('[SEED] Inserted ${ayahs.length} ayah texts');
    } catch (e) {
      debugPrint('[SEED] ERROR seeding ayah text: $e');
    }
  }

}

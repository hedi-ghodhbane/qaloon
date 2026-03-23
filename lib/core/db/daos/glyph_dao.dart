import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/glyph_table.dart';

part 'glyph_dao.g.dart';

@DriftAccessor(tables: [GlyphTable])
class GlyphDao extends DatabaseAccessor<AppDatabase> with _$GlyphDaoMixin {
  GlyphDao(super.db);

  Future<List<GlyphTableData>> getGlyphsForPage(
    int pageNumber,
    int riwayaId,
  ) {
    return (select(glyphTable)
          ..where(
            (g) =>
                g.pageNumber.equals(pageNumber) &
                g.riwayaId.equals(riwayaId),
          )
          ..orderBy([(g) => OrderingTerm.asc(g.lineNumber)]))
        .get();
  }

  Future<List<GlyphTableData>> getGlyphsForAyah(
    int surahId,
    int ayahNumber,
    int riwayaId,
  ) {
    return (select(glyphTable)
          ..where(
            (g) =>
                g.surahId.equals(surahId) &
                g.ayahNumber.equals(ayahNumber) &
                g.riwayaId.equals(riwayaId),
          ))
        .get();
  }

  /// Finds the glyph ayah number closest to [textAyahNumber] on [pageNumber]
  /// for [surahId]. Needed because glyph and ayah-text numbering can differ
  /// (bismillah counted differently).
  Future<int?> findGlyphAyah({
    required int pageNumber,
    required int surahId,
    required int textAyahNumber,
    required int riwayaId,
  }) async {
    final glyphs = await (select(glyphTable)
          ..where((g) =>
              g.pageNumber.equals(pageNumber) &
              g.surahId.equals(surahId) &
              g.riwayaId.equals(riwayaId))
          ..orderBy([(g) => OrderingTerm.asc(g.ayahNumber)]))
        .get();
    if (glyphs.isEmpty) return null;

    // Collect unique ayah numbers on this page for this surah.
    final ayahNums = glyphs.map((g) => g.ayahNumber).toSet().toList()..sort();

    // Find closest to textAyahNumber (offset is usually 0 or ±1).
    int best = ayahNums.first;
    int bestDiff = (best - textAyahNumber).abs();
    for (final a in ayahNums) {
      final diff = (a - textAyahNumber).abs();
      if (diff < bestDiff) {
        best = a;
        bestDiff = diff;
      }
    }
    return best;
  }

  Future<void> insertGlyphs(List<GlyphTableCompanion> glyphs) {
    return batch((b) => b.insertAll(glyphTable, glyphs));
  }
}

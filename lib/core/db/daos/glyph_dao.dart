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

  Future<void> insertGlyphs(List<GlyphTableCompanion> glyphs) {
    return batch((b) => b.insertAll(glyphTable, glyphs));
  }
}

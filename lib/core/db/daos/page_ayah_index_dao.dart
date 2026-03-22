import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/page_ayah_index_table.dart';

part 'page_ayah_index_dao.g.dart';

@DriftAccessor(tables: [PageAyahIndexTable])
class PageAyahIndexDao extends DatabaseAccessor<AppDatabase>
    with _$PageAyahIndexDaoMixin {
  PageAyahIndexDao(super.db);

  /// Get all surah/ayah entries on a specific page.
  Future<List<PageAyahIndexTableData>> getSurahsOnPage(
    int pageNumber,
    int riwayaId,
  ) {
    return (select(pageAyahIndexTable)
          ..where(
            (p) =>
                p.pageNumber.equals(pageNumber) &
                p.riwayaId.equals(riwayaId),
          )
          ..orderBy([
            (p) => OrderingTerm.asc(p.surahId),
            (p) => OrderingTerm.asc(p.ayahNumber),
          ]))
        .get();
  }

  /// Get the first page of a specific surah.
  Future<int?> getFirstPageOfSurah(int surahId, int riwayaId) async {
    final query = selectOnly(pageAyahIndexTable)
      ..addColumns([pageAyahIndexTable.pageNumber.min()])
      ..where(
        pageAyahIndexTable.surahId.equals(surahId) &
            pageAyahIndexTable.riwayaId.equals(riwayaId),
      );

    final result = await query.getSingle();
    return result.read(pageAyahIndexTable.pageNumber.min());
  }

  /// Get the page containing a specific ayah of a surah.
  Future<int?> getPageOfAyah(int surahId, int ayahNumber, int riwayaId) async {
    final query = select(pageAyahIndexTable)
      ..where(
        (p) =>
            p.surahId.equals(surahId) &
            p.ayahNumber.equals(ayahNumber) &
            p.riwayaId.equals(riwayaId),
      )
      ..limit(1);

    final results = await query.get();
    if (results.isNotEmpty) return results.first.pageNumber;

    // Fallback: find the page where this ayah would be
    // (last page with ayahNumber <= requested)
    final fallback = selectOnly(pageAyahIndexTable)
      ..addColumns([pageAyahIndexTable.pageNumber.max()])
      ..where(
        pageAyahIndexTable.surahId.equals(surahId) &
            pageAyahIndexTable.ayahNumber.isSmallerOrEqualValue(ayahNumber) &
            pageAyahIndexTable.riwayaId.equals(riwayaId),
      );
    final result = await fallback.getSingle();
    return result.read(pageAyahIndexTable.pageNumber.max());
  }

  Future<void> insertEntries(List<PageAyahIndexTableCompanion> entries) {
    return batch((b) => b.insertAll(pageAyahIndexTable, entries));
  }
}

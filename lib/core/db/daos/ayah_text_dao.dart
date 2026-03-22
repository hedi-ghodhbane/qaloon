import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/ayah_text_table.dart';

part 'ayah_text_dao.g.dart';

@DriftAccessor(tables: [AyahTextTable])
class AyahTextDao extends DatabaseAccessor<AppDatabase>
    with _$AyahTextDaoMixin {
  AyahTextDao(super.db);

  /// Search ayah text containing the query string.
  Future<List<AyahTextTableData>> searchText(String query, {int limit = 30}) {
    return (select(ayahTextTable)
          ..where((a) => a.ayahText.contains(query))
          ..limit(limit))
        .get();
  }

  /// Get text for a specific ayah.
  Future<AyahTextTableData?> getAyahText(int surahId, int ayahNumber) {
    return (select(ayahTextTable)
          ..where(
            (a) =>
                a.surahId.equals(surahId) & a.ayahNumber.equals(ayahNumber),
          ))
        .getSingleOrNull();
  }

  Future<int> count() async {
    final c = countAll();
    final query = selectOnly(ayahTextTable)..addColumns([c]);
    final result = await query.getSingle();
    return result.read(c) ?? 0;
  }

  Future<void> insertAyahs(List<AyahTextTableCompanion> ayahs) {
    return batch((b) => b.insertAll(ayahTextTable, ayahs));
  }
}

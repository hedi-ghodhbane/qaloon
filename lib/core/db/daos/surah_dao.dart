import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/surah_table.dart';

part 'surah_dao.g.dart';

@DriftAccessor(tables: [SurahTable])
class SurahDao extends DatabaseAccessor<AppDatabase> with _$SurahDaoMixin {
  SurahDao(super.db);

  Future<List<SurahTableData>> getAllSurahs() {
    return (select(surahTable)..orderBy([(s) => OrderingTerm.asc(s.id)])).get();
  }

  Future<SurahTableData?> getSurahById(int id) {
    return (select(surahTable)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> insertSurahs(List<SurahTableCompanion> surahs) {
    return batch((b) => b.insertAll(surahTable, surahs));
  }
}

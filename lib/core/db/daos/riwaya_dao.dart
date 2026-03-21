import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/riwaya_table.dart';

part 'riwaya_dao.g.dart';

@DriftAccessor(tables: [RiwayaTable])
class RiwayaDao extends DatabaseAccessor<AppDatabase> with _$RiwayaDaoMixin {
  RiwayaDao(super.db);

  Future<List<RiwayaTableData>> getAllRiwayas() {
    return select(riwayaTable).get();
  }

  Future<RiwayaTableData?> getRiwayaByKey(String key) {
    return (select(riwayaTable)..where((r) => r.key.equals(key)))
        .getSingleOrNull();
  }

  Stream<List<RiwayaTableData>> watchAllRiwayas() {
    return select(riwayaTable).watch();
  }

  Future<void> markDownloaded(int id) {
    return (update(riwayaTable)..where((r) => r.id.equals(id))).write(
      RiwayaTableCompanion(
        isDownloaded: const Value(true),
        downloadedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markUndownloaded(int id) {
    return (update(riwayaTable)..where((r) => r.id.equals(id))).write(
      const RiwayaTableCompanion(
        isDownloaded: Value(false),
        downloadedAt: Value(null),
      ),
    );
  }

  Future<void> insertRiwayas(List<RiwayaTableCompanion> riwayas) {
    return batch((b) => b.insertAll(riwayaTable, riwayas));
  }
}

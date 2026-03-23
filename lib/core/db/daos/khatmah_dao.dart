import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/khatmah_table.dart';
import '../tables/khatmah_day_table.dart';

part 'khatmah_dao.g.dart';

@DriftAccessor(tables: [KhatmahTable, KhatmahDayTable])
class KhatmahDao extends DatabaseAccessor<AppDatabase>
    with _$KhatmahDaoMixin {
  KhatmahDao(super.db);

  static const _totalPages = 604;

  /// Creates a new khatmah and generates day rows.
  Future<int> createKhatmah({
    required String name,
    required int totalDays,
    required int riwayaId,
  }) async {
    // Deactivate any existing active khatmah.
    await (update(khatmahTable)..where((k) => k.isActive.equals(true)))
        .write(const KhatmahTableCompanion(isActive: Value(false)));

    final pagesPerDay = (_totalPages / totalDays).ceil();

    final khatmahId = await into(khatmahTable).insert(
      KhatmahTableCompanion.insert(
        name: name,
        totalDays: totalDays,
        startDate: DateTime.now(),
        riwayaId: riwayaId,
        pagesPerDay: pagesPerDay,
        createdAt: DateTime.now(),
      ),
    );

    // Generate day rows.
    final days = <KhatmahDayTableCompanion>[];
    for (int i = 0; i < totalDays; i++) {
      final startPage = i * pagesPerDay + 1;
      var endPage = (i + 1) * pagesPerDay;
      if (endPage > _totalPages) endPage = _totalPages;
      // Last day gets remaining pages.
      if (i == totalDays - 1) endPage = _totalPages;

      days.add(KhatmahDayTableCompanion.insert(
        khatmahId: khatmahId,
        dayNumber: i + 1,
        startPage: startPage,
        endPage: endPage,
      ));
    }

    await batch((b) => b.insertAll(khatmahDayTable, days));
    return khatmahId;
  }

  /// Returns the currently active khatmah, or null.
  Future<KhatmahTableData?> getActiveKhatmah() {
    return (select(khatmahTable)..where((k) => k.isActive.equals(true)))
        .getSingleOrNull();
  }

  /// Watch active khatmah for reactive UI.
  Stream<KhatmahTableData?> watchActiveKhatmah() {
    return (select(khatmahTable)..where((k) => k.isActive.equals(true)))
        .watchSingleOrNull();
  }

  /// Returns all days for a khatmah, ordered by day number.
  Future<List<KhatmahDayTableData>> getKhatmahDays(int khatmahId) {
    return (select(khatmahDayTable)
          ..where((d) => d.khatmahId.equals(khatmahId))
          ..orderBy([(d) => OrderingTerm.asc(d.dayNumber)]))
        .get();
  }

  /// Returns the first incomplete day (current day to read).
  Future<KhatmahDayTableData?> getCurrentDay(int khatmahId) {
    return (select(khatmahDayTable)
          ..where((d) =>
              d.khatmahId.equals(khatmahId) & d.isCompleted.equals(false))
          ..orderBy([(d) => OrderingTerm.asc(d.dayNumber)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Marks a day as completed.
  Future<void> markDayCompleted(int dayId) {
    return (update(khatmahDayTable)..where((d) => d.id.equals(dayId))).write(
      KhatmahDayTableCompanion(
        isCompleted: const Value(true),
        completedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Returns completed day count for a khatmah.
  Future<int> completedDayCount(int khatmahId) async {
    final count = khatmahDayTable.id.count();
    final query = selectOnly(khatmahDayTable)
      ..addColumns([count])
      ..where(khatmahDayTable.khatmahId.equals(khatmahId) &
          khatmahDayTable.isCompleted.equals(true));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Deletes a khatmah and its days.
  Future<void> deleteKhatmah(int khatmahId) async {
    await (delete(khatmahDayTable)
          ..where((d) => d.khatmahId.equals(khatmahId)))
        .go();
    await (delete(khatmahTable)..where((k) => k.id.equals(khatmahId))).go();
  }
}

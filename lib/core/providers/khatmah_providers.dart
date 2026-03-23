import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/app_database.dart';
import 'db_provider.dart';

final activeKhatmahProvider =
    AsyncNotifierProvider<ActiveKhatmahNotifier, KhatmahTableData?>(
  ActiveKhatmahNotifier.new,
);

class ActiveKhatmahNotifier extends AsyncNotifier<KhatmahTableData?> {
  @override
  Future<KhatmahTableData?> build() {
    final db = ref.watch(appDatabaseProvider);
    return db.khatmahDao.getActiveKhatmah();
  }

  Future<int> create({
    required String name,
    required int totalDays,
    required int riwayaId,
  }) async {
    final db = ref.read(appDatabaseProvider);
    final id = await db.khatmahDao.createKhatmah(
      name: name,
      totalDays: totalDays,
      riwayaId: riwayaId,
    );
    ref.invalidateSelf();
    return id;
  }

  Future<void> abandon(int khatmahId) async {
    final db = ref.read(appDatabaseProvider);
    await db.khatmahDao.deleteKhatmah(khatmahId);
    ref.invalidateSelf();
  }
}

final khatmahDaysProvider =
    FutureProvider.family<List<KhatmahDayTableData>, int>((ref, khatmahId) {
  final db = ref.watch(appDatabaseProvider);
  return db.khatmahDao.getKhatmahDays(khatmahId);
});

final currentKhatmahDayProvider =
    FutureProvider.family<KhatmahDayTableData?, int>((ref, khatmahId) {
  final db = ref.watch(appDatabaseProvider);
  return db.khatmahDao.getCurrentDay(khatmahId);
});

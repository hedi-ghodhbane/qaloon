import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/daos/reading_session_dao.dart';
import '../models/reading_stats.dart';
import 'db_provider.dart';

final readingStatsProvider =
    FutureProvider.family.autoDispose<ReadingStats, int>(
  (ref, riwayaId) async {
    final db = ref.watch(appDatabaseProvider);
    final dao = db.readingSessionDao;

    final today = await dao.pagesReadOnDate(DateTime.now(), riwayaId);
    final weekData = await dao.pagesReadPerDay(7, riwayaId);
    final monthData = await dao.pagesReadPerDay(30, riwayaId);
    final total = await dao.totalPagesRead(riwayaId);
    final streak = await dao.calculateStreak(riwayaId);

    return ReadingStats(
      todayPages: today,
      weekPages: weekData.fold(0, (sum, d) => sum + d.pages),
      monthPages: monthData.fold(0, (sum, d) => sum + d.pages),
      totalPages: total,
      streak: streak,
    );
  },
);

typedef DailyChartParams = ({int riwayaId, int days});

final dailyChartProvider =
    FutureProvider.family.autoDispose<List<DailyPageCount>, DailyChartParams>(
  (ref, params) async {
    final db = ref.watch(appDatabaseProvider);
    return db.readingSessionDao.pagesReadPerDay(params.days, params.riwayaId);
  },
);

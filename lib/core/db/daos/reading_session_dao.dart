import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/reading_session_table.dart';

part 'reading_session_dao.g.dart';

@DriftAccessor(tables: [ReadingSessionTable])
class ReadingSessionDao extends DatabaseAccessor<AppDatabase>
    with _$ReadingSessionDaoMixin {
  ReadingSessionDao(super.db);

  Future<void> insertSession({
    required DateTime date,
    required int startPage,
    required int endPage,
    required int pagesRead,
    required int riwayaId,
  }) {
    return into(readingSessionTable).insert(
      ReadingSessionTableCompanion.insert(
        date: date,
        startPage: startPage,
        endPage: endPage,
        pagesRead: pagesRead,
        riwayaId: riwayaId,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<List<ReadingSessionTableData>> getAllSessions(int riwayaId) {
    return (select(readingSessionTable)
          ..where((s) => s.riwayaId.equals(riwayaId))
          ..orderBy([(s) => OrderingTerm.desc(s.date)]))
        .get();
  }

  Future<int> pagesReadOnDate(DateTime date, int riwayaId) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = selectOnly(readingSessionTable)
      ..addColumns([readingSessionTable.pagesRead.sum()])
      ..where(
        readingSessionTable.date.isBetweenValues(startOfDay, endOfDay) &
            readingSessionTable.riwayaId.equals(riwayaId),
      );

    final result = await query.getSingle();
    return result.read(readingSessionTable.pagesRead.sum()) ?? 0;
  }

  Future<List<DailyPageCount>> pagesReadPerDay(
    int days,
    int riwayaId,
  ) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day - days + 1);

    final query = select(readingSessionTable)
      ..where(
        (s) =>
            s.date.isBiggerOrEqualValue(startDate) &
            s.riwayaId.equals(riwayaId),
      );

    final sessions = await query.get();
    final Map<String, int> dailyMap = {};

    for (final session in sessions) {
      final key =
          '${session.date.year}-${session.date.month}-${session.date.day}';
      dailyMap[key] = (dailyMap[key] ?? 0) + session.pagesRead;
    }

    final result = <DailyPageCount>[];
    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final key = '${date.year}-${date.month}-${date.day}';
      result.add(DailyPageCount(date: date, pages: dailyMap[key] ?? 0));
    }
    return result;
  }

  Future<int> totalPagesRead(int riwayaId) async {
    final query = selectOnly(readingSessionTable)
      ..addColumns([readingSessionTable.pagesRead.sum()])
      ..where(readingSessionTable.riwayaId.equals(riwayaId));

    final result = await query.getSingle();
    return result.read(readingSessionTable.pagesRead.sum()) ?? 0;
  }

  Future<int> calculateStreak(int riwayaId) async {
    final dailyData = await pagesReadPerDay(365, riwayaId);
    int streak = 0;

    for (int i = dailyData.length - 1; i >= 0; i--) {
      if (dailyData[i].pages > 0) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}

class DailyPageCount {
  final DateTime date;
  final int pages;

  const DailyPageCount({required this.date, required this.pages});
}

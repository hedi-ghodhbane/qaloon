import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/app_database.dart';
import 'db_provider.dart';

final bookmarkNotifierProvider =
    AsyncNotifierProvider<BookmarkNotifier, BookmarkTableData?>(
  BookmarkNotifier.new,
);

class BookmarkNotifier extends AsyncNotifier<BookmarkTableData?> {
  @override
  Future<BookmarkTableData?> build() {
    final db = ref.watch(appDatabaseProvider);
    return db.bookmarkDao.getBookmark();
  }

  Future<void> setBookmark({
    required int pageNumber,
    int? surahId,
    int? ayahNumber,
    required int riwayaId,
  }) async {
    final db = ref.read(appDatabaseProvider);
    await db.bookmarkDao.upsertBookmark(
      pageNumber: pageNumber,
      surahId: surahId,
      ayahNumber: ayahNumber,
      riwayaId: riwayaId,
    );
    ref.invalidateSelf();
  }

  Future<void> clearBookmark() async {
    final db = ref.read(appDatabaseProvider);
    await db.bookmarkDao.clearBookmark();
    ref.invalidateSelf();
  }
}

final bookmarkStreamProvider = StreamProvider<BookmarkTableData?>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.bookmarkDao.watchBookmark();
});

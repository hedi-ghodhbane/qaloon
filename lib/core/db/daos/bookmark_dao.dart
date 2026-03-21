import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/bookmark_table.dart';

part 'bookmark_dao.g.dart';

@DriftAccessor(tables: [BookmarkTable])
class BookmarkDao extends DatabaseAccessor<AppDatabase>
    with _$BookmarkDaoMixin {
  BookmarkDao(super.db);

  Future<BookmarkTableData?> getBookmark() {
    return (select(bookmarkTable)..where((b) => b.id.equals(1)))
        .getSingleOrNull();
  }

  Stream<BookmarkTableData?> watchBookmark() {
    return (select(bookmarkTable)..where((b) => b.id.equals(1)))
        .watchSingleOrNull();
  }

  Future<void> upsertBookmark({
    required int pageNumber,
    int? surahId,
    int? ayahNumber,
    required int riwayaId,
  }) {
    return into(bookmarkTable).insertOnConflictUpdate(
      BookmarkTableCompanion.insert(
        id: const Value(1),
        pageNumber: pageNumber,
        surahId: Value(surahId),
        ayahNumber: Value(ayahNumber),
        riwayaId: riwayaId,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> clearBookmark() {
    return (delete(bookmarkTable)..where((b) => b.id.equals(1))).go();
  }
}

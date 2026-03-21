import 'package:drift/drift.dart';

class PageAyahIndexTable extends Table {
  IntColumn get pageNumber => integer()();
  IntColumn get surahId => integer()();
  IntColumn get ayahNumber => integer()();
  IntColumn get riwayaId => integer()();

  @override
  Set<Column> get primaryKey => {pageNumber, surahId, ayahNumber, riwayaId};
}

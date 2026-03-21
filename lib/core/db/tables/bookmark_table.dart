import 'package:drift/drift.dart';

class BookmarkTable extends Table {
  IntColumn get id => integer()();
  IntColumn get pageNumber => integer()();
  IntColumn get surahId => integer().nullable()();
  IntColumn get ayahNumber => integer().nullable()();
  IntColumn get riwayaId => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

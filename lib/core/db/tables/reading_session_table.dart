import 'package:drift/drift.dart';

class ReadingSessionTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get startPage => integer()();
  IntColumn get endPage => integer()();
  IntColumn get pagesRead => integer()();
  IntColumn get riwayaId => integer()();
  DateTimeColumn get createdAt => dateTime()();
}

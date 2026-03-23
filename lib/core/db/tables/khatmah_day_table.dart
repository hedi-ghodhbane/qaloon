import 'package:drift/drift.dart';

class KhatmahDayTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get khatmahId => integer()();
  IntColumn get dayNumber => integer()();
  IntColumn get startPage => integer()();
  IntColumn get endPage => integer()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

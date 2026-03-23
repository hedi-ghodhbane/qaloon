import 'package:drift/drift.dart';

class KhatmahTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get totalDays => integer()();
  DateTimeColumn get startDate => dateTime()();
  IntColumn get riwayaId => integer()();
  IntColumn get pagesPerDay => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
}

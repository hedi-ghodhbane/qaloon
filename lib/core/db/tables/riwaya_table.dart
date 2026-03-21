import 'package:drift/drift.dart';

class RiwayaTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().unique()();
  TextColumn get displayName => text()();
  BoolColumn get isBundled => boolean().withDefault(const Constant(false))();
  BoolColumn get isDownloaded => boolean().withDefault(const Constant(false))();
  DateTimeColumn get downloadedAt => dateTime().nullable()();
  IntColumn get imageNativeWidth => integer().withDefault(const Constant(2268))();
  IntColumn get totalPages => integer().withDefault(const Constant(604))();
}

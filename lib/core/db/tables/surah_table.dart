import 'package:drift/drift.dart';

class SurahTable extends Table {
  IntColumn get id => integer()();
  TextColumn get nameArabic => text()();
  TextColumn get nameTransliterated => text()();
  IntColumn get ayahCount => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

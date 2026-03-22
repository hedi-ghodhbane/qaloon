import 'package:drift/drift.dart';

class AyahTextTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get surahId => integer()();
  IntColumn get ayahNumber => integer()();
  IntColumn get pageNumber => integer()();
  TextColumn get text => text()();
}

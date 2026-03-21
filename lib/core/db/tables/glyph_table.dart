import 'package:drift/drift.dart';

class GlyphTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pageNumber => integer()();
  IntColumn get lineNumber => integer()();
  IntColumn get surahId => integer()();
  IntColumn get ayahNumber => integer()();
  IntColumn get position => integer()();
  IntColumn get minX => integer()();
  IntColumn get maxX => integer()();
  IntColumn get minY => integer()();
  IntColumn get maxY => integer()();
  IntColumn get riwayaId => integer()();
}

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/ayah_text_table.dart';

part 'ayah_text_dao.g.dart';

/// Arabic tashkeel / diacritics Unicode codepoints to strip for search.
final _tashkeelPattern = RegExp(
  '[\u064B-\u065F\u0610-\u061A\u0656-\u065E'
  '\u0670\u06D6-\u06ED\u06EC\u08D3-\u08FF'
  '\u0640'   // tatweel
  '\u06E5\u06E6'  // small waw/yaa
  '\u0660-\u0669' // Arabic-Indic digits (ayah numbers embedded in text)
  '\u06F0-\u06F9' // Extended Arabic-Indic digits
  ']',
);

/// Strip tashkeel and normalize common alef/hamza forms.
String normalizeArabic(String text) {
  var s = text.replaceAll(_tashkeelPattern, '');
  // Normalize alef variants → bare alef
  s = s.replaceAll(RegExp('[\u0622\u0623\u0625\u0627\u0671]'), '\u0627');
  // Normalize taa marbuta → haa
  s = s.replaceAll('\u0629', '\u0647');
  // Normalize alef maqsura → yaa
  s = s.replaceAll('\u0649', '\u064A');
  return s;
}

@DriftAccessor(tables: [AyahTextTable])
class AyahTextDao extends DatabaseAccessor<AppDatabase>
    with _$AyahTextDaoMixin {
  AyahTextDao(super.db);

  /// Search using the pre-normalized column for diacritics-insensitive matching.
  Future<List<AyahTextTableData>> searchText(String query, {int limit = 30}) {
    final normalized = normalizeArabic(query);
    return (select(ayahTextTable)
          ..where((a) => a.textNormalized.contains(normalized))
          ..limit(limit))
        .get();
  }

  /// Get text for a specific ayah.
  Future<AyahTextTableData?> getAyahText(int surahId, int ayahNumber) {
    return (select(ayahTextTable)
          ..where(
            (a) =>
                a.surahId.equals(surahId) & a.ayahNumber.equals(ayahNumber),
          ))
        .getSingleOrNull();
  }

  Future<int> count() async {
    final c = countAll();
    final query = selectOnly(ayahTextTable)..addColumns([c]);
    final result = await query.getSingle();
    return result.read(c) ?? 0;
  }

  Future<void> insertAyahs(List<AyahTextTableCompanion> ayahs) {
    return batch((b) => b.insertAll(ayahTextTable, ayahs));
  }
}

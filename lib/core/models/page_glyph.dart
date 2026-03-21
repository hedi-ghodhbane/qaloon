import 'dart:ui';

class PageGlyph {
  final int id;
  final int pageNumber;
  final int lineNumber;
  final int surahId;
  final int ayahNumber;
  final int position;
  final Rect rect;

  const PageGlyph({
    required this.id,
    required this.pageNumber,
    required this.lineNumber,
    required this.surahId,
    required this.ayahNumber,
    required this.position,
    required this.rect,
  });

  /// Unique key for this ayah (surah:ayah).
  (int, int) get ayahKey => (surahId, ayahNumber);
}

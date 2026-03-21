import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../models/page_glyph.dart';
import 'db_provider.dart';

final currentPageProvider = StateNotifierProvider<CurrentPageNotifier, int>(
  (ref) => CurrentPageNotifier(),
);

class CurrentPageNotifier extends StateNotifier<int> {
  CurrentPageNotifier() : super(1);

  void setPage(int page) {
    state = page.clamp(1, kTotalPages);
  }
}

final currentRiwayaIdProvider =
    StateNotifierProvider<CurrentRiwayaIdNotifier, int>(
  (ref) => CurrentRiwayaIdNotifier(),
);

class CurrentRiwayaIdNotifier extends StateNotifier<int> {
  CurrentRiwayaIdNotifier() : super(kQalounRiwayaId);

  void setRiwaya(int id) {
    state = id;
  }
}

typedef GlyphParams = ({
  int pageNumber,
  int riwayaId,
  double screenWidth,
  int imageNativeWidth,
});

final glyphsForPageProvider =
    FutureProvider.family.autoDispose<List<PageGlyph>, GlyphParams>(
  (ref, params) async {
    final db = ref.watch(appDatabaseProvider);
    final glyphs = await db.glyphDao.getGlyphsForPage(
      params.pageNumber,
      params.riwayaId,
    );

    final scale = params.screenWidth / params.imageNativeWidth;

    return glyphs
        .map(
          (g) => PageGlyph(
            id: g.id,
            pageNumber: g.pageNumber,
            lineNumber: g.lineNumber,
            surahId: g.surahId,
            ayahNumber: g.ayahNumber,
            position: g.position,
            rect: Rect.fromLTRB(
              g.minX * scale,
              g.minY * scale,
              g.maxX * scale,
              g.maxY * scale,
            ),
          ),
        )
        .toList();
  },
);

typedef PageHeaderParams = ({int pageNumber, int riwayaId});

final pageHeaderProvider =
    FutureProvider.family.autoDispose<String, PageHeaderParams>(
  (ref, params) async {
    final db = ref.watch(appDatabaseProvider);
    final entries = await db.pageAyahIndexDao.getSurahsOnPage(
      params.pageNumber,
      params.riwayaId,
    );
    if (entries.isEmpty) return 'صفحة ${params.pageNumber}';

    final surahIds = entries.map((e) => e.surahId).toSet();
    final names = <String>[];
    for (final id in surahIds) {
      final surah = await db.surahDao.getSurahById(id);
      if (surah != null) names.add(surah.nameArabic);
    }
    return names.join(' - ');
  },
);

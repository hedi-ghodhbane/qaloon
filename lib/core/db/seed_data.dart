import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';

import 'app_database.dart';

/// Qaloun surah start pages (1-indexed). Index 0 = surah 1.
/// Derived from standard Qaloun Mushaf print.
const _qalounSurahStartPages = [
  1, 2, 50, 77, 106, 128, 151, 177, 187, 208,
  221, 235, 249, 255, 262, 267, 282, 293, 305, 312,
  322, 332, 342, 350, 359, 367, 377, 385, 396, 404,
  411, 415, 418, 428, 434, 440, 446, 453, 462, 467,
  477, 483, 489, 496, 499, 502, 507, 511, 515, 518,
  520, 523, 526, 528, 531, 534, 537, 542, 545, 549,
  551, 553, 554, 556, 558, 560, 562, 564, 566, 568,
  570, 572, 574, 575, 577, 578, 580, 582, 583, 585,
  586, 587, 587, 589, 590, 591, 591, 592, 593, 594,
  595, 595, 596, 596, 597, 597, 598, 598, 599, 599,
  600, 600, 601, 601, 601, 602, 602, 602, 603, 603,
  603, 604, 604, 604,
];

/// Seeds surah metadata from bundled surahs.json.
Future<void> seedSurahs(AppDatabase db) async {
  final existing = await db.surahDao.getAllSurahs();
  if (existing.isNotEmpty) return;

  final jsonStr = await rootBundle.loadString('assets/metadata/surahs.json');
  final List<dynamic> surahs = json.decode(jsonStr);

  final companions = surahs.map((s) => SurahTableCompanion.insert(
        id: Value(s['id'] as int),
        nameArabic: s['nameArabic'] as String,
        nameTransliterated: s['nameTransliterated'] as String,
        ayahCount: s['ayahCount'] as int,
      ));

  await db.surahDao.insertSurahs(companions.toList());
}

/// Seeds page-to-surah index for Qaloun (riwayaId=1).
Future<void> seedPageAyahIndex(AppDatabase db) async {
  final existing = await (db.select(db.pageAyahIndexTable)..limit(1)).get();
  if (existing.isNotEmpty) return;

  const riwayaId = 1;
  final rows = <PageAyahIndexTableCompanion>[];

  for (int surah = 1; surah <= 114; surah++) {
    final startPage = _qalounSurahStartPages[surah - 1];
    final endPage = surah < 114
        ? _qalounSurahStartPages[surah] - 1
        : 604;

    for (int page = startPage; page <= endPage; page++) {
      rows.add(PageAyahIndexTableCompanion.insert(
        pageNumber: page,
        surahId: surah,
        ayahNumber: 1,
        riwayaId: riwayaId,
      ));
    }
  }

  await db.batch((b) => b.insertAll(db.pageAyahIndexTable, rows));
}

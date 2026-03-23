import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/quran_divisions.dart';
import '../../core/db/app_database.dart';
import '../../core/providers/db_provider.dart';
import '../../core/providers/reader_providers.dart';
import '../navigation/surah_list.dart';

/// Provider that pre-fetches the starting ayah text for all 240 quarters.
final _quarterAyahTextsProvider =
    FutureProvider<Map<int, AyahTextTableData>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final map = <int, AyahTextTableData>{};
  for (int i = 0; i < kQalounDivisions.length; i++) {
    final d = kQalounDivisions[i];
    final text = await db.ayahTextDao.getAyahText(d.surah, d.ayah);
    if (text != null) map[i] = text;
  }
  return map;
});

/// Provides all surahs for drawer name lookup.
final _allSurahsProvider = FutureProvider<List<SurahTableData>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.surahDao.getAllSurahs();
});

class MushafDrawer extends StatelessWidget {
  const MushafDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Tab toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor:
                        Theme.of(context).colorScheme.primary,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerHeight: 0,
                    tabs: const [
                      Tab(text: 'السور'),
                      Tab(text: 'الأرباع'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Tab content
              const Expanded(
                child: TabBarView(
                  children: [
                    _SurahsTab(),
                    _QuartersTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Surahs Tab ──────────────────────────────────────────────────────────────

class _SurahsTab extends ConsumerWidget {
  const _SurahsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(allSurahsProvider);

    return surahsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (surahs) => ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: surahs.length,
        itemBuilder: (context, index) {
          final surah = surahs[index];
          return _DrawerSurahTile(surah: surah);
        },
      ),
    );
  }
}

class _DrawerSurahTile extends ConsumerWidget {
  final SurahTableData surah;
  const _DrawerSurahTile({required this.surah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          '${surah.id}',
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
      title: Text(
        surah.nameArabic,
        style: const TextStyle(
          fontFamily: 'Noto Naskh Arabic',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${surah.nameTransliterated} • ${surah.ayahCount} آيات',
        style: const TextStyle(fontSize: 12),
      ),
      onTap: () async {
        final riwayaId = ref.read(currentRiwayaIdProvider);
        final db = ref.read(appDatabaseProvider);
        final page =
            await db.pageAyahIndexDao.getFirstPageOfSurah(surah.id, riwayaId);
        if (page != null && context.mounted) {
          ref.read(currentPageProvider.notifier).setPage(page);
          Navigator.of(context).pop();
        }
      },
    );
  }
}

// ─── Quarters Tab ────────────────────────────────────────────────────────────

class _QuartersTab extends ConsumerWidget {
  const _QuartersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);
    final textsAsync = ref.watch(_quarterAyahTextsProvider);
    final surahsAsync = ref.watch(_allSurahsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return textsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (texts) {
        final surahs = surahsAsync.valueOrNull ?? [];
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: 30,
          itemBuilder: (context, juzIndex) {
            final juz = juzIndex + 1;
            final quarters = divisionsForJuz(juz);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Juz header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'الجزء $juz',
                    style: TextStyle(
                      fontFamily: 'Noto Naskh Arabic',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ...quarters.map((q) {
                  final idx = kQalounDivisions.indexOf(q);
                  final ayahText = texts[idx];
                  final isCurrent = _isCurrent(q, currentPage);
                  final surahName = _getSurahName(surahs, q.surah);

                  return _QuarterDrawerTile(
                    division: q,
                    ayahText: ayahText?.ayahText,
                    surahName: surahName,
                    isCurrent: isCurrent,
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  bool _isCurrent(QuranDivision q, int currentPage) {
    final idx = kQalounDivisions.indexOf(q);
    final nextPage = idx + 1 < kQalounDivisions.length
        ? kQalounDivisions[idx + 1].startPage
        : 605;
    return currentPage >= q.startPage && currentPage < nextPage;
  }

  String _getSurahName(List<SurahTableData> surahs, int surahId) {
    final match = surahs.where((s) => s.id == surahId).firstOrNull;
    return match?.nameTransliterated ?? '';
  }
}

class _QuarterDrawerTile extends ConsumerWidget {
  final QuranDivision division;
  final String? ayahText;
  final String surahName;
  final bool isCurrent;

  const _QuarterDrawerTile({
    required this.division,
    this.ayahText,
    required this.surahName,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isHizbStart = division.quarter == 1;

    return InkWell(
      onTap: () {
        ref.read(currentPageProvider.notifier).setPage(division.startPage);
        Navigator.of(context).pop();
      },
      child: Container(
        color: isCurrent ? colorScheme.primary.withValues(alpha: 0.1) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Hizb/quarter indicator
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent
                    ? colorScheme.primary
                    : isHizbStart
                        ? colorScheme.onSurface.withValues(alpha: 0.12)
                        : colorScheme.onSurface.withValues(alpha: 0.06),
                border: isCurrent
                    ? null
                    : Border.all(
                        color: colorScheme.onSurface.withValues(alpha: 0.15),
                      ),
              ),
              alignment: Alignment.center,
              child: isHizbStart
                  ? Text(
                      '${division.hizb}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isCurrent
                            ? Colors.white
                            : colorScheme.onSurface,
                      ),
                    )
                  : Text(
                      const {2: '¼', 3: '½', 4: '¾'}[division.quarter] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isCurrent
                            ? Colors.white
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // Ayah text + metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (ayahText != null)
                    Text(
                      _truncateAyah(ayahText!),
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Noto Naskh Arabic',
                        fontSize: 15,
                        color: colorScheme.onSurface,
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    '$surahName: ${division.ayah} - صفحة ${division.startPage}',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _truncateAyah(String text) {
    if (text.length <= 60) return text;
    return '${text.substring(0, 60)}…';
  }
}

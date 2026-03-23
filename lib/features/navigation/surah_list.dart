import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/app_database.dart';
import '../../core/providers/db_provider.dart';
import '../../core/providers/reader_providers.dart';

import '../../shared/widgets/loading_indicator.dart';

final allSurahsProvider = FutureProvider<List<SurahTableData>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.surahDao.getAllSurahs();
});

class SurahList extends ConsumerStatefulWidget {
  const SurahList({super.key});

  @override
  ConsumerState<SurahList> createState() => _SurahListState();
}

class _SurahListState extends ConsumerState<SurahList> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Parse ayah reference. Supports:
  /// "2:255", "2 255", "البقرة 255", "البقرة:255", "baqarah 255"
  ({int surahId, int ayahNumber})? _parseAyahRef(
    List<SurahTableData> surahs,
  ) {
    final q = _query.trim();
    if (q.isEmpty) return null;

    // "number:number" or "number number"
    final numPattern = RegExp(r'^(\d+)\s*[:：\s]\s*(\d+)$');
    final numMatch = numPattern.firstMatch(q);
    if (numMatch != null) {
      final sid = int.parse(numMatch.group(1)!);
      final ayah = int.parse(numMatch.group(2)!);
      if (sid >= 1 && sid <= 114) {
        return (surahId: sid, ayahNumber: ayah);
      }
    }

    // "text:number" or "text number"
    final textPattern = RegExp(r'^(.+?)\s*[:：\s]\s*(\d+)$');
    final textMatch = textPattern.firstMatch(q);
    if (textMatch != null) {
      final name = textMatch.group(1)!.trim().toLowerCase();
      final ayah = int.parse(textMatch.group(2)!);
      for (final s in surahs) {
        if (s.nameArabic.contains(name) ||
            s.nameTransliterated.toLowerCase().contains(name)) {
          return (surahId: s.id, ayahNumber: ayah);
        }
      }
    }
    return null;
  }

  List<SurahTableData> _filter(List<SurahTableData> surahs) {
    if (_query.isEmpty) return surahs;
    final q = _query.toLowerCase();
    final asNumber = int.tryParse(q);
    return surahs.where((s) {
      if (asNumber != null && s.id == asNumber) return true;
      return s.nameArabic.contains(_query) ||
          s.nameTransliterated.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _goToAyah(int surahId, int ayahNumber) async {
    final riwayaId = ref.read(currentRiwayaIdProvider);
    final db = ref.read(appDatabaseProvider);
    final page = await db.pageAyahIndexDao
        .getPageOfAyah(surahId, ayahNumber, riwayaId);
    if (page != null && mounted) {
      ref.read(currentPageProvider.notifier).setPage(page);
      if (mounted) context.go('/');
      // Delay flash so new page loads glyphs first.
      Future.delayed(const Duration(milliseconds: 500), () {
        if (ref.exists(highlightAyahProvider)) {
          ref.read(highlightAyahProvider.notifier).state = (surahId, ayahNumber);
        }
        Future.delayed(const Duration(seconds: 3), () {
          if (ref.exists(highlightAyahProvider)) {
            ref.read(highlightAyahProvider.notifier).state = null;
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final surahsAsync = ref.watch(allSurahsProvider);

    return surahsAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => Center(child: Text('$e')),
      data: (allSurahs) {
        final surahs = _filter(allSurahs);
        final ayahRef = _parseAyahRef(allSurahs);

        // Find surah name for ayah ref display
        String? ayahLabel;
        if (ayahRef != null) {
          final match = allSurahs
              .where((s) => s.id == ayahRef.surahId)
              .firstOrNull;
          if (match != null) {
            ayahLabel = '${match.nameArabic} : ${ayahRef.ayahNumber}';
          }
        }

        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'سورة أو آية... (مثال: 2:255)',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            // Ayah reference action
            if (ayahRef != null && ayahLabel != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Material(
                  color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _goToAyah(ayahRef.surahId, ayahRef.ayahNumber),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.my_location, size: 20,
                              color: Theme.of(context).colorScheme.tertiary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'الانتقال إلى $ayahLabel',
                              style: const TextStyle(
                                fontFamily: 'Noto Naskh Arabic',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            // Results
            Expanded(
              child: surahs.isEmpty && ayahRef == null
                  ? const Center(child: Text('لا توجد نتائج'))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: surahs.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, indent: 72),
                      itemBuilder: (context, index) {
                        final surah = surahs[index];
                        return _SurahTile(surah: surah);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _SurahTile extends ConsumerWidget {
  final SurahTableData surah;
  const _SurahTile({required this.surah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          '${surah.id}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      title: Text(
        surah.nameArabic,
        style: const TextStyle(
          fontFamily: 'Noto Naskh Arabic',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${surah.nameTransliterated} • ${surah.ayahCount} آيات',
        style: const TextStyle(fontSize: 13),
      ),
      trailing: const Icon(Icons.chevron_left, size: 20),
      onTap: () async {
        final riwayaId = ref.read(currentRiwayaIdProvider);
        final db = ref.read(appDatabaseProvider);
        final page =
            await db.pageAyahIndexDao.getFirstPageOfSurah(surah.id, riwayaId);
        if (page != null && context.mounted) {
          ref.read(currentPageProvider.notifier).setPage(page);
          context.go('/');
          // Delay flash so new page loads glyphs first.
          Future.delayed(const Duration(milliseconds: 500), () {
            if (ref.exists(highlightAyahProvider)) {
              ref.read(highlightAyahProvider.notifier).state = (surah.id, 1);
            }
            Future.delayed(const Duration(seconds: 3), () {
              if (ref.exists(highlightAyahProvider)) {
                ref.read(highlightAyahProvider.notifier).state = null;
              }
            });
          });
        }
      },
    );
  }
}

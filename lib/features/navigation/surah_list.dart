import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/app_database.dart';
import '../../core/providers/db_provider.dart';
import '../../core/providers/reader_providers.dart';
import '../../shared/theme/colors.dart';
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

  List<SurahTableData> _filter(List<SurahTableData> surahs) {
    if (_query.isEmpty) return surahs;
    final q = _query.toLowerCase();
    // Allow searching by number (e.g. "2" → Al-Baqarah)
    final asNumber = int.tryParse(q);
    return surahs.where((s) {
      if (asNumber != null && s.id == asNumber) return true;
      return s.nameArabic.contains(_query) ||
          s.nameTransliterated.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final surahsAsync = ref.watch(allSurahsProvider);

    return surahsAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => Center(child: Text('$e')),
      data: (allSurahs) {
        final surahs = _filter(allSurahs);
        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'ابحث عن سورة...',
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
                  fillColor: AppColors.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            // Results
            Expanded(
              child: surahs.isEmpty
                  ? const Center(child: Text('لا توجد نتائج'))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: surahs.length,
                      separatorBuilder: (_, __) =>
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
        }
      },
    );
  }
}

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

class SurahList extends ConsumerWidget {
  const SurahList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(allSurahsProvider);

    return surahsAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => Center(child: Text('$e')),
      data: (surahs) => ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: surahs.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          final surah = surahs[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
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
              final page = await db.pageAyahIndexDao
                  .getFirstPageOfSurah(surah.id, riwayaId);
              if (page != null && context.mounted) {
                ref.read(currentPageProvider.notifier).setPage(page);
                context.go('/');
              }
            },
          );
        },
      ),
    );
  }
}

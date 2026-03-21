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
      data: (surahs) => ListView.builder(
        itemCount: surahs.length,
        itemBuilder: (context, index) {
          final surah = surahs[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              child: Text('${surah.id}'),
            ),
            title: Text(
              surah.nameArabic,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${surah.nameTransliterated} • ${surah.ayahCount} آيات',
            ),
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

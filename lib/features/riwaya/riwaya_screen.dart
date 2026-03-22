import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/providers/db_provider.dart';
import '../../core/providers/riwaya_providers.dart';
import '../../shared/theme/colors.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'download_service.dart';

final _downloadServiceProvider = Provider((ref) => DownloadService());

class RiwayaScreen extends ConsumerWidget {
  const RiwayaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riwayasAsync = ref.watch(riwayaListProvider);
    final activeDownloadId = ref.watch(activeDownloadProvider);
    final progress = ref.watch(downloadProgressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الروايات')),
      body: riwayasAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('$e')),
        data: (riwayas) => ListView.builder(
          itemCount: riwayas.length,
          itemBuilder: (context, index) {
            final riwaya = riwayas[index];
            final isDownloading = activeDownloadId == riwaya.id;

            return _RiwayaTile(
              riwaya: riwaya,
              isDownloading: isDownloading,
              progress: isDownloading ? progress : 0,
              onDownload: () =>
                  _startDownload(ref, riwaya),
              onDelete: () =>
                  _deleteRiwaya(ref, riwaya),
            );
          },
        ),
      ),
    );
  }

  Future<void> _startDownload(WidgetRef ref, RiwayaTableData riwaya) async {
    final service = ref.read(_downloadServiceProvider);
    final db = ref.read(appDatabaseProvider);

    ref.read(activeDownloadProvider.notifier).setDownloading(riwaya.id);
    ref.read(downloadProgressProvider.notifier).reset();

    try {
      await for (final progress in service.downloadRemainingPages(riwayaKey: riwaya.key)) {
        ref.read(downloadProgressProvider.notifier).update(progress);
      }
      await db.riwayaDao.markDownloaded(riwaya.id);
    } finally {
      ref.read(activeDownloadProvider.notifier).clearDownloading();
    }
  }

  Future<void> _deleteRiwaya(WidgetRef ref, RiwayaTableData riwaya) async {
    final service = ref.read(_downloadServiceProvider);
    final db = ref.read(appDatabaseProvider);

    await service.deleteRiwaya(riwaya.key);
    await db.riwayaDao.markUndownloaded(riwaya.id);
  }
}

class _RiwayaTile extends StatelessWidget {
  final RiwayaTableData riwaya;
  final bool isDownloading;
  final double progress;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _RiwayaTile({
    required this.riwaya,
    required this.isDownloading,
    required this.progress,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  riwaya.displayName,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (riwaya.isDownloaded)
                  const Icon(Icons.check_circle, color: AppColors.primary)
                else if (isDownloading)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (isDownloading) ...[
              LinearProgressIndicator(
                value: progress,
                color: AppColors.primary,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 4),
              Text('${(progress * 100).toInt()}%'),
            ] else if (riwaya.isBundled && riwaya.isDownloaded) ...[
              const Row(
                children: [
                  Icon(Icons.verified, color: AppColors.primary, size: 18),
                  SizedBox(width: 6),
                  Text('مثبّتة مسبقاً'),
                ],
              ),
            ] else if (riwaya.isDownloaded) ...[
              Row(
                children: [
                  const Text('تم التحميل'),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    label: const Text('حذف', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: onDownload,
                icon: const Icon(Icons.download),
                label: const Text('تحميل'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

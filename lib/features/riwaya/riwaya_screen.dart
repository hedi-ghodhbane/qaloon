import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/riwaya_providers.dart';
import '../../shared/theme/colors.dart';

class RiwayaScreen extends ConsumerWidget {
  const RiwayaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dlState = ref.watch(pageDownloadProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الروايات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Qaloun card — always shown.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'قالون عن نافع',
                        style: TextStyle(
                          fontFamily: 'Noto Naskh Arabic',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (dlState.isComplete)
                        const Icon(Icons.check_circle, color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (dlState.isComplete) ...[
                    const Row(
                      children: [
                        Icon(Icons.verified, color: AppColors.primary, size: 18),
                        SizedBox(width: 6),
                        Text('جميع الصفحات متوفرة'),
                      ],
                    ),
                  ] else if (dlState.isDownloading) ...[
                    LinearProgressIndicator(
                      value: dlState.progress,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'جارٍ التحميل... ${(dlState.progress * 100).toInt()}%',
                    ),
                  ] else if (dlState.error != null) ...[
                    Text(
                      'خطأ: ${dlState.error}',
                      style: const TextStyle(color: AppColors.error),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () =>
                          ref.read(pageDownloadProvider.notifier).retry(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: () =>
                          ref.read(pageDownloadProvider.notifier).startDownload(),
                      icon: const Icon(Icons.download),
                      label: const Text('تحميل الصفحات'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Placeholder for future riwayat.
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ورش عن نافع',
                    style: TextStyle(
                      fontFamily: 'Noto Naskh Arabic',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'قريباً إن شاء الله',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

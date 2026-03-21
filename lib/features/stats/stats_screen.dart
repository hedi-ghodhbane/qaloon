import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/reader_providers.dart';
import '../../core/providers/stats_providers.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'widgets/daily_bar_chart.dart';
import 'widgets/summary_card.dart';
import 'widgets/streak_card.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riwayaId = ref.watch(currentRiwayaIdProvider);
    final statsAsync = ref.watch(readingStatsProvider(riwayaId));
    final chartAsync = ref.watch(
      dailyChartProvider((riwayaId: riwayaId, days: 7)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('إحصائيات القراءة')),
      body: statsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('$e')),
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StreakCard(streak: stats.streak),
              const SizedBox(height: 16),
              SummaryCard(stats: stats),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'آخر 7 أيام',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: chartAsync.when(
                          loading: () => const LoadingIndicator(),
                          error: (e, _) => Center(child: Text('$e')),
                          data: (data) => DailyBarChart(data: data),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

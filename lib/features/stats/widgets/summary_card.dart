import 'package:flutter/material.dart';
import '../../../core/models/reading_stats.dart';

class SummaryCard extends StatelessWidget {
  final ReadingStats stats;

  const SummaryCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ملخص', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            _StatRow(label: 'اليوم', value: '${stats.todayPages} صفحة'),
            _StatRow(label: 'هذا الأسبوع', value: '${stats.weekPages} صفحة'),
            _StatRow(label: 'هذا الشهر', value: '${stats.monthPages} صفحة'),
            _StatRow(label: 'المجموع', value: '${stats.totalPages} صفحة'),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

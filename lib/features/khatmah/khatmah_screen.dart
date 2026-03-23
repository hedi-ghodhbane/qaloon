import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/app_database.dart';
import '../../core/providers/db_provider.dart';
import '../../core/providers/khatmah_providers.dart';
import '../../core/providers/reader_providers.dart';

class KhatmahScreen extends ConsumerWidget {
  const KhatmahScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final khatmahAsync = ref.watch(activeKhatmahProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الختمة')),
      body: khatmahAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (khatmah) {
          if (khatmah == null) {
            return _KhatmahCreator();
          }
          return _KhatmahProgress(khatmah: khatmah);
        },
      ),
    );
  }
}

// ─── Template Picker / Creator ───────────────────────────────────────────────

class _KhatmahCreator extends ConsumerStatefulWidget {
  @override
  ConsumerState<_KhatmahCreator> createState() => _KhatmahCreatorState();
}

class _KhatmahCreatorState extends ConsumerState<_KhatmahCreator> {
  int? _customDays;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _create(String name, int days) async {
    final riwayaId = ref.read(currentRiwayaIdProvider);
    await ref
        .read(activeKhatmahProvider.notifier)
        .create(name: name, totalDays: days, riwayaId: riwayaId);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pagesPerDay604 = (604 / 29).ceil(); // ~21
    final pagesPerDay7 = (604 / 7).ceil(); // ~87

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        Icon(Icons.menu_book_rounded, size: 64, color: colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          'ابدأ ختمة جديدة',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Noto Naskh Arabic',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'اختر خطة لإتمام القرآن الكريم',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 32),

        // Template: 29 days
        _TemplateCard(
          title: 'ختمة شهرية',
          subtitle: '$pagesPerDay604 صفحة يومياً • 29 يوم',
          icon: Icons.calendar_month,
          onTap: () => _create('ختمة شهرية', 29),
        ),
        const SizedBox(height: 12),

        // Template: 7 days (Sahaba)
        _TemplateCard(
          title: 'ختمة الصحابة',
          subtitle: '$pagesPerDay7 صفحة يومياً • 7 أيام',
          icon: Icons.bolt,
          onTap: () => _create('ختمة الصحابة', 7),
        ),
        const SizedBox(height: 12),

        // Custom
        _TemplateCard(
          title: 'ختمة مخصصة',
          subtitle: _customDays != null
              ? '${(604 / _customDays!).ceil()} صفحة يومياً • $_customDays يوم'
              : 'اختر عدد الأيام',
          icon: Icons.tune,
          trailing: SizedBox(
            width: 80,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'أيام',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (v) {
                final days = int.tryParse(v);
                setState(() {
                  _customDays = (days != null && days > 0 && days <= 604)
                      ? days
                      : null;
                });
              },
            ),
          ),
          onTap: _customDays != null
              ? () => _create('ختمة مخصصة', _customDays!)
              : null,
        ),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _TemplateCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Noto Naskh Arabic',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Active Khatmah Progress ─────────────────────────────────────────────────

class _KhatmahProgress extends ConsumerWidget {
  final KhatmahTableData khatmah;

  const _KhatmahProgress({required this.khatmah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysAsync = ref.watch(khatmahDaysProvider(khatmah.id));
    final currentDayAsync = ref.watch(currentKhatmahDayProvider(khatmah.id));
    final colorScheme = Theme.of(context).colorScheme;

    return daysAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (days) {
        final completedCount = days.where((d) => d.isCompleted).length;
        final progress = completedCount / khatmah.totalDays;
        final currentDay = currentDayAsync.valueOrNull;

        return Column(
          children: [
            // Header with progress
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: colorScheme.primary.withValues(alpha: 0.08),
              child: Column(
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: colorScheme.onSurface.withValues(
                            alpha: 0.1,
                          ),
                          color: colorScheme.primary,
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    khatmah.name,
                    style: TextStyle(
                      fontFamily: 'Noto Naskh Arabic',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completedCount من ${khatmah.totalDays} يوم',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Day list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];
                  final isCurrent = currentDay?.id == day.id;

                  return _DayTile(
                    day: day,
                    isCurrent: isCurrent,
                    khatmahId: khatmah.id,
                  );
                },
              ),
            ),

            // Abandon button
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton.icon(
                icon: Icon(Icons.delete_outline, color: colorScheme.error),
                label: Text(
                  'حذف الختمة',
                  style: TextStyle(color: colorScheme.error),
                ),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('حذف الختمة؟'),
                      content: const Text('سيتم حذف الختمة وجميع بياناتها.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('إلغاء'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(
                            'حذف',
                            style: TextStyle(color: colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref
                        .read(activeKhatmahProvider.notifier)
                        .abandon(khatmah.id);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DayTile extends ConsumerWidget {
  final KhatmahDayTableData day;
  final bool isCurrent;
  final int khatmahId;

  const _DayTile({
    required this.day,
    required this.isCurrent,
    required this.khatmahId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        ref.read(currentPageProvider.notifier).setPage(day.startPage);
        context.go('/');
      },
      child: Container(
        color: isCurrent ? colorScheme.primary.withValues(alpha: 0.08) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Day number badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: day.isCompleted
                    ? colorScheme.primary
                    : isCurrent
                    ? colorScheme.primary.withValues(alpha: 0.15)
                    : colorScheme.onSurface.withValues(alpha: 0.05),
              ),
              alignment: Alignment.center,
              child: day.isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                      '${day.dayNumber}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isCurrent
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // Day info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اليوم ${day.dayNumber}',
                    style: TextStyle(
                      fontFamily: 'Noto Naskh Arabic',
                      fontSize: 15,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'صفحة ${day.startPage} – ${day.endPage}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Mark done button for current day
            if (isCurrent)
              FilledButton.tonal(
                onPressed: () async {
                  final db = ref.read(appDatabaseProvider);
                  await db.khatmahDao.markDayCompleted(day.id);
                  ref.invalidate(khatmahDaysProvider(khatmahId));
                  ref.invalidate(currentKhatmahDayProvider(khatmahId));
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 32),
                ),
                child: const Text('تم ✓', style: TextStyle(fontSize: 13)),
              ),
          ],
        ),
      ),
    );
  }
}

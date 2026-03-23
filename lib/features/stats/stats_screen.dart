import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/reading_stats.dart';
import '../../core/providers/db_provider.dart';
import '../../core/providers/reader_providers.dart';
import '../../core/providers/stats_providers.dart';
import '../../shared/theme/colors.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'widgets/daily_bar_chart.dart';

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
      appBar: AppBar(
        title: const Text('إحصائياتي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'إعادة تعيين',
            onPressed: () => _showResetDialog(context, ref, riwayaId),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('$e')),
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Streak hero
              _StreakHero(streak: stats.streak),
              const SizedBox(height: 20),

              // Quick stats row
              _QuickStatsRow(stats: stats),
              const SizedBox(height: 20),

              // Progress ring — how much of the Quran read
              _ProgressRing(totalPages: stats.totalPages),
              const SizedBox(height: 20),

              // Weekly chart
              _SectionHeader(title: 'آخر ٧ أيام'),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 180,
                    child: chartAsync.when(
                      loading: () => const LoadingIndicator(),
                      error: (e, _) => Center(child: Text('$e')),
                      data: (data) => DailyBarChart(data: data),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Achievements
              _SectionHeader(title: 'الإنجازات'),
              const SizedBox(height: 8),
              _AchievementsGrid(stats: stats),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref, int riwayaId) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('إعادة تعيين'),
          ],
        ),
        content: const Text(
          'سيتم حذف جميع بيانات القراءة والإنجازات. هذا الإجراء لا يمكن التراجع عنه.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final db = ref.read(appDatabaseProvider);
              await db.readingSessionDao.deleteAllSessions(riwayaId);
              ref.invalidate(readingStatsProvider(riwayaId));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إعادة التعيين')),
                );
              }
            },
            child: const Text('حذف الكل'),
          ),
        ],
      ),
    );
  }
}

// ─── Streak Hero ────────────────────────────────────────────────────────────

class _StreakHero extends StatelessWidget {
  final int streak;
  const _StreakHero({required this.streak});

  String get _emoji {
    if (streak >= 30) return '🔥';
    if (streak >= 7) return '⭐';
    if (streak >= 3) return '✨';
    return '🌱';
  }

  String get _subtitle {
    if (streak == 0) return 'ابدأ القراءة اليوم!';
    if (streak == 1) return 'بداية موفقة!';
    if (streak < 7) return 'استمر!';
    if (streak < 30) return 'ما شاء الله!';
    return 'بارك الله فيك!';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(_emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(
            '$streak',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'أيام متتالية',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontFamily: 'Noto Naskh Arabic',
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _subtitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'Noto Naskh Arabic',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Stats Row ────────────────────────────────────────────────────────

class _QuickStatsRow extends StatelessWidget {
  final ReadingStats stats;
  const _QuickStatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            label: 'اليوم',
            value: '${stats.todayPages}',
            icon: Icons.today,
            color: const Color(0xFF2196F3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            label: 'الأسبوع',
            value: '${stats.weekPages}',
            icon: Icons.date_range,
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            label: 'الشهر',
            value: '${stats.monthPages}',
            icon: Icons.calendar_month,
            color: AppColors.gold,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─── Progress Ring ──────────────────────────────────────────────────────────

class _ProgressRing extends StatelessWidget {
  final int totalPages;
  const _ProgressRing({required this.totalPages});

  @override
  Widget build(BuildContext context) {
    const quranPages = 604;
    final khatmaat = totalPages ~/ quranPages;
    final currentProgress = (totalPages % quranPages) / quranPages;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Ring
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: currentProgress,
                      strokeWidth: 8,
                      backgroundColor: AppColors.divider,
                      color: AppColors.primary,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '${(currentProgress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'التقدم في الختمة',
                    style: TextStyle(
                      fontFamily: 'Noto Naskh Arabic',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalPages / $quranPages صفحة',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (khatmaat > 0) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '🏆 $khatmaat ${khatmaat == 1 ? "ختمة" : "ختمات"}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Achievements ───────────────────────────────────────────────────────────

class _Achievement {
  final String title;
  final String description;
  final String emoji;
  final bool unlocked;

  const _Achievement({
    required this.title,
    required this.description,
    required this.emoji,
    required this.unlocked,
  });
}

List<_Achievement> _buildAchievements(ReadingStats stats) {
  return [
    _Achievement(
      title: 'الخطوة الأولى',
      description: 'اقرأ صفحة واحدة',
      emoji: '📖',
      unlocked: stats.totalPages >= 1,
    ),
    _Achievement(
      title: 'قارئ يومي',
      description: 'اقرأ ٣ أيام متتالية',
      emoji: '📅',
      unlocked: stats.streak >= 3,
    ),
    _Achievement(
      title: 'جزء كامل',
      description: 'اقرأ ٢٠ صفحة',
      emoji: '📚',
      unlocked: stats.totalPages >= 20,
    ),
    _Achievement(
      title: 'أسبوع كامل',
      description: '٧ أيام متتالية',
      emoji: '⭐',
      unlocked: stats.streak >= 7,
    ),
    _Achievement(
      title: 'نصف حزب',
      description: 'اقرأ ٥٠ صفحة',
      emoji: '🌙',
      unlocked: stats.totalPages >= 50,
    ),
    _Achievement(
      title: 'مثابر',
      description: '١٤ يوماً متتالياً',
      emoji: '💪',
      unlocked: stats.streak >= 14,
    ),
    _Achievement(
      title: 'ربع القرآن',
      description: 'اقرأ ١٥١ صفحة',
      emoji: '🌟',
      unlocked: stats.totalPages >= 151,
    ),
    _Achievement(
      title: 'شهر كامل',
      description: '٣٠ يوماً متتالياً',
      emoji: '🔥',
      unlocked: stats.streak >= 30,
    ),
    _Achievement(
      title: 'نصف القرآن',
      description: 'اقرأ ٣٠٢ صفحة',
      emoji: '✨',
      unlocked: stats.totalPages >= 302,
    ),
    _Achievement(
      title: 'خاتم القرآن',
      description: 'أتمم ختمة كاملة',
      emoji: '🏆',
      unlocked: stats.totalPages >= 604,
    ),
    _Achievement(
      title: 'الحافظ',
      description: '١٠٠ يوم متتالي',
      emoji: '👑',
      unlocked: stats.streak >= 100,
    ),
    _Achievement(
      title: 'ختمتان',
      description: 'أتمم ختمتين',
      emoji: '💎',
      unlocked: stats.totalPages >= 1208,
    ),
  ];
}

class _AchievementsGrid extends StatelessWidget {
  final ReadingStats stats;
  const _AchievementsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final achievements = _buildAchievements(stats);
    final unlocked = achievements.where((a) => a.unlocked).length;

    return Column(
      children: [
        // Unlocked counter
        Text(
          '$unlocked / ${achievements.length} إنجاز',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.85,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final a = achievements[index];
            return _AchievementTile(achievement: a);
          },
        ),
      ],
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final _Achievement achievement;
  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.unlocked;

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${achievement.emoji} ${achievement.title}: ${achievement.description}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: unlocked
              ? AppColors.gold.withValues(alpha: 0.1)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unlocked
                ? AppColors.gold.withValues(alpha: 0.3)
                : AppColors.divider,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              unlocked ? achievement.emoji : '🔒',
              style: TextStyle(
                fontSize: 28,
                color: unlocked ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Noto Naskh Arabic',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: unlocked
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Noto Naskh Arabic',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

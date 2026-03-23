import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/quran_divisions.dart';
import '../../core/providers/reader_providers.dart';

const _quarterLabels = ['بداية الحزب', 'ربع', 'نصف', 'ثلاثة أرباع'];

class JuzList extends ConsumerWidget {
  const JuzList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);
    final currentDiv = divisionForPage(currentPage);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 30,
      itemBuilder: (context, index) {
        final juz = index + 1;
        final quarters = divisionsForJuz(juz);
        final isCurrentJuz = currentDiv.juz == juz;

        return _JuzExpansionTile(
          juz: juz,
          quarters: quarters,
          isCurrentJuz: isCurrentJuz,
          currentPage: currentPage,
        );
      },
    );
  }
}

class _JuzExpansionTile extends ConsumerWidget {
  final int juz;
  final List<QuranDivision> quarters;
  final bool isCurrentJuz;
  final int currentPage;

  const _JuzExpansionTile({
    required this.juz,
    required this.quarters,
    required this.isCurrentJuz,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final firstPage = quarters.first.startPage;
    final hizb1 = quarters.first.hizb;
    final hizb2 = quarters.length > 4 ? quarters[4].hizb : hizb1;

    return ExpansionTile(
      initiallyExpanded: isCurrentJuz,
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.only(bottom: 8),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isCurrentJuz
              ? colorScheme.primary.withValues(alpha: 0.15)
              : colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          '$juz',
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      title: Text(
        'الجزء $juz',
        style: TextStyle(
          fontFamily: 'Noto Naskh Arabic',
          fontSize: 17,
          fontWeight: isCurrentJuz ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
      subtitle: Text(
        'الحزب $hizb1 – $hizb2 • صفحة $firstPage',
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      children: [
        _HizbSection(
          hizb: hizb1,
          quarters: quarters.take(4).toList(),
          currentPage: currentPage,
        ),
        if (quarters.length > 4)
          _HizbSection(
            hizb: hizb2,
            quarters: quarters.skip(4).toList(),
            currentPage: currentPage,
          ),
      ],
    );
  }
}

class _HizbSection extends ConsumerWidget {
  final int hizb;
  final List<QuranDivision> quarters;
  final int currentPage;

  const _HizbSection({
    required this.hizb,
    required this.quarters,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(72, 8, 16, 4),
          child: Text(
            'الحزب $hizb',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colorScheme.tertiary,
            ),
          ),
        ),
        ...quarters.map((q) {
          final isCurrent = _isCurrentQuarter(q);
          return _QuarterTile(
            division: q,
            isCurrent: isCurrent,
          );
        }),
      ],
    );
  }

  bool _isCurrentQuarter(QuranDivision q) {
    final idx = kQalounDivisions.indexOf(q);
    if (idx == -1) return false;
    final nextPage = idx + 1 < kQalounDivisions.length
        ? kQalounDivisions[idx + 1].startPage
        : 605;
    return currentPage >= q.startPage && currentPage < nextPage;
  }
}

class _QuarterTile extends ConsumerWidget {
  final QuranDivision division;
  final bool isCurrent;

  const _QuarterTile({
    required this.division,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = _quarterLabels[division.quarter - 1];

    return InkWell(
      onTap: () {
        ref.read(currentPageProvider.notifier).setPage(division.startPage);
        context.go('/');
      },
      child: Container(
        color: isCurrent ? colorScheme.primary.withValues(alpha: 0.08) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const SizedBox(width: 56),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Noto Naskh Arabic',
                  fontSize: 14,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: isCurrent ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
            ),
            Text(
              'ص ${division.startPage}',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

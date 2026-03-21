import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/reader_providers.dart';

/// Juz starting pages for Qaloun Riwaya (standard Mushaf).
/// These are the same across most prints. Index 0 = Juz 1.
const _juzStartPages = [
  1, 22, 42, 62, 82, 102, 121, 142, 162, 182, //
  201, 222, 242, 262, 282, 302, 322, 342, 362, 382,
  402, 422, 442, 462, 482, 502, 522, 542, 562, 582,
];

class JuzList extends ConsumerWidget {
  const JuzList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: 30,
      itemBuilder: (context, index) {
        final juzNumber = index + 1;
        final startPage = _juzStartPages[index];

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            child: Text('$juzNumber'),
          ),
          title: Text(
            'الجزء $juzNumber',
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text('يبدأ من صفحة $startPage'),
          onTap: () {
            ref.read(currentPageProvider.notifier).setPage(startPage);
            context.go('/');
          },
        );
      },
    );
  }
}

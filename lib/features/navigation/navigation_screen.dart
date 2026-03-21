import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'surah_list.dart';
import 'juz_list.dart';
import 'page_jump_dialog.dart';

class NavigationScreen extends ConsumerWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الفهرس'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'السور'),
              Tab(text: 'الأجزاء'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.numbers),
              tooltip: 'الانتقال إلى صفحة',
              onPressed: () => showPageJumpDialog(context, ref),
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            SurahList(),
            JuzList(),
          ],
        ),
      ),
    );
  }
}

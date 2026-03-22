import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:share_plus/share_plus.dart';

import '../../core/providers/db_provider.dart';
import '../../core/providers/reader_providers.dart';
import '../../core/providers/theme_provider.dart';
import '../../shared/theme/colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // — Appearance section
          _SectionHeader(title: 'المظهر'),
          SwitchListTile(
            secondary: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: AppColors.primary,
            ),
            title: const Text('الوضع الليلي'),
            subtitle: Text(isDark ? 'مفعّل' : 'معطّل'),
            value: isDark,
            activeColor: AppColors.primary,
            onChanged: (_) =>
                ref.read(themeModeProvider.notifier).toggle(),
          ),
          const Divider(indent: 72),

          // — Data section
          _SectionHeader(title: 'البيانات'),
          ListTile(
            leading: const Icon(Icons.upload_file, color: AppColors.primary),
            title: const Text('تصدير البيانات'),
            subtitle: const Text('نسخة احتياطية من تقدمك'),
            onTap: () => _exportData(context, ref),
          ),
          const Divider(indent: 72),
          ListTile(
            leading: const Icon(Icons.download, color: AppColors.primary),
            title: const Text('استيراد البيانات'),
            subtitle: const Text('استعادة من نسخة سابقة'),
            onTap: () => _importData(context, ref),
          ),
          const Divider(indent: 72),

          // — About section
          _SectionHeader(title: 'حول'),
          const ListTile(
            leading: Icon(Icons.info_outline, color: AppColors.primary),
            title: Text('الإصدار'),
            subtitle: Text('1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.auto_stories, color: AppColors.primary),
            title: Text('الرواية'),
            subtitle: Text('قالون عن نافع'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      final db = ref.read(appDatabaseProvider);
      final riwayaId = ref.read(currentRiwayaIdProvider);

      // Gather all data
      final bookmark = await db.bookmarkDao.getBookmark();
      final sessions = await db.readingSessionDao.getAllSessions(riwayaId);

      final exportData = {
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'app': 'qaloon',
        'bookmark': bookmark != null
            ? {
                'pageNumber': bookmark.pageNumber,
                'surahId': bookmark.surahId,
                'ayahNumber': bookmark.ayahNumber,
                'riwayaId': bookmark.riwayaId,
              }
            : null,
        'sessions': sessions
            .map((s) => {
                  'date': s.date.toIso8601String(),
                  'startPage': s.startPage,
                  'endPage': s.endPage,
                  'pagesRead': s.pagesRead,
                  'riwayaId': s.riwayaId,
                })
            .toList(),
      };

      final json = const JsonEncoder.withIndent('  ').convert(exportData);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/qaloon_backup.json');
      await file.writeAsString(json);

      if (!context.mounted) return;

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'نسخة احتياطية - قالون',
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في التصدير: $e')),
      );
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    // For now, show a simple dialog explaining import.
    // Full file-picker import can be added later.
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('استيراد البيانات'),
        content: const Text(
          'لاستيراد بياناتك، ضع ملف qaloon_backup.json في مجلد التطبيق ثم أعد تشغيل التطبيق.\n\n'
          'سيتم دعم الاستيراد المباشر قريباً.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

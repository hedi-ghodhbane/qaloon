import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/app_database.dart';
import '../../core/providers/db_provider.dart';
import '../../core/providers/reader_providers.dart';
import '../../shared/theme/colors.dart';

class AyahSearch extends ConsumerStatefulWidget {
  const AyahSearch({super.key});

  @override
  ConsumerState<AyahSearch> createState() => _AyahSearchState();
}

class _AyahSearchState extends ConsumerState<AyahSearch> {
  final _controller = TextEditingController();
  List<AyahTextTableData> _results = [];
  bool _loading = false;
  String _lastQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2 || trimmed == _lastQuery) return;
    _lastQuery = trimmed;

    setState(() => _loading = true);
    final db = ref.read(appDatabaseProvider);
    final results = await db.ayahTextDao.searchText(trimmed);
    if (mounted) {
      setState(() {
        _results = results;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            controller: _controller,
            onChanged: _search,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'ابحث في نص القرآن...',
              hintTextDirection: TextDirection.rtl,
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _results = [];
                          _lastQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (_results.isEmpty && _lastQuery.length >= 2)
          const Expanded(child: Center(child: Text('لا توجد نتائج')))
        else if (_results.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'اكتب كلمة أو جزء من آية للبحث',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final ayah = _results[index];
                return _AyahResultTile(ayah: ayah, query: _lastQuery);
              },
            ),
          ),
      ],
    );
  }
}

class _AyahResultTile extends ConsumerWidget {
  final AyahTextTableData ayah;
  final String query;

  const _AyahResultTile({required this.ayah, required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Build highlighted text
    final text = ayah.ayahText;
    final spans = _buildHighlightedSpans(text, query);

    return InkWell(
      onTap: () {
        ref.read(currentPageProvider.notifier).setPage(ayah.pageNumber);
        context.go('/');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Surah:Ayah label + page
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${ayah.surahId}:${ayah.ayahNumber}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'صفحة ${ayah.pageNumber}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Ayah text with highlighted query
            RichText(
              textDirection: TextDirection.rtl,
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Noto Naskh Arabic',
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  height: 1.8,
                ),
                children: spans,
              ),
            ),
            const Divider(height: 16),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _buildHighlightedSpans(String text, String query) {
    if (query.isEmpty) return [TextSpan(text: text)];

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;

    while (true) {
      final idx = lowerText.indexOf(lowerQuery, start);
      if (idx == -1) {
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start)));
        }
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx)));
      }
      spans.add(
        TextSpan(
          text: text.substring(idx, idx + query.length),
          style: const TextStyle(
            backgroundColor: AppColors.goldHighlight,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      start = idx + query.length;
    }

    return spans.isEmpty ? [TextSpan(text: text)] : spans;
  }
}

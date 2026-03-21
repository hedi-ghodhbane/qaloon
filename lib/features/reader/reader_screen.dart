import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/providers/bookmark_provider.dart';
import '../../core/providers/reader_providers.dart';
import '../../shared/theme/colors.dart';
import 'mushaf_page_view.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  bool _showOverlay = true;
  final _pageViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleOverlay() {
    setState(() => _showOverlay = !_showOverlay);
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(currentPageProvider);
    final riwayaId = ref.watch(currentRiwayaIdProvider);
    final bookmark = ref.watch(bookmarkNotifierProvider);

    final isBookmarked = bookmark.whenOrNull(
          data: (b) => b?.pageNumber == currentPage,
        ) ??
        false;

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: _toggleOverlay,
        child: Stack(
          children: [
            MushafPageView(
              key: _pageViewKey,
              initialPage: currentPage,
              riwayaId: riwayaId,
              riwayaKey: RiwayaKeys.qaloun,
              imageNativeWidth: kQalounImageNativeWidth,
              isBundled: true,
            ),
            if (_showOverlay) ...[
              // Top bar: page number + surah name.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'صفحة $currentPage',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: isBookmarked
                                  ? AppColors.gold
                                  : Colors.white,
                            ),
                            onPressed: () => _toggleBookmark(currentPage, riwayaId),
                          ),
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () => context.push('/navigation'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom bar: navigation shortcuts.
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 8,
                    left: 16,
                    right: 16,
                    top: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _BottomAction(
                        icon: Icons.bar_chart,
                        label: 'إحصائيات',
                        onTap: () => context.push('/stats'),
                      ),
                      _BottomAction(
                        icon: Icons.library_books,
                        label: 'الروايات',
                        onTap: () => context.push('/riwaya'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _toggleBookmark(int currentPage, int riwayaId) {
    ref.read(bookmarkNotifierProvider.notifier).setBookmark(
          pageNumber: currentPage,
          riwayaId: riwayaId,
        );
  }
}

class _BottomAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

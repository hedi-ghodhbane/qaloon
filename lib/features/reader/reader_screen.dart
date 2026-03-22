import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/providers/bookmark_provider.dart';
import '../../core/providers/db_provider.dart';
import '../../core/providers/reader_providers.dart';
import '../../shared/theme/colors.dart';
import 'mushaf_page_view.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen>
    with WidgetsBindingObserver {
  bool _showOverlay = true;
  final _pageViewKey = GlobalKey();

  // Session tracking
  final Set<int> _visitedPages = {};
  int? _sessionStartPage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _sessionStartPage = ref.read(currentPageProvider);
    _visitedPages.add(_sessionStartPage!);
  }

  @override
  void dispose() {
    _saveSession();
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveSession();
    }
  }

  void _saveSession() {
    if (_visitedPages.isEmpty || _sessionStartPage == null) return;
    final riwayaId = ref.read(currentRiwayaIdProvider);
    final endPage = ref.read(currentPageProvider);
    final pagesRead = _visitedPages.length;
    if (pagesRead == 0) return;

    final db = ref.read(appDatabaseProvider);
    db.readingSessionDao.insertSession(
      date: DateTime.now(),
      startPage: _sessionStartPage!,
      endPage: endPage,
      pagesRead: pagesRead,
      riwayaId: riwayaId,
    );
    debugPrint('[SESSION] Saved: $pagesRead pages read '
        '($_sessionStartPage→$endPage)');
    // Reset for next session
    _visitedPages.clear();
    _sessionStartPage = ref.read(currentPageProvider);
    _visitedPages.add(_sessionStartPage!);
  }

  void _toggleOverlay() {
    setState(() => _showOverlay = !_showOverlay);
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(currentPageProvider);
    final riwayaId = ref.watch(currentRiwayaIdProvider);
    final bookmark = ref.watch(bookmarkNotifierProvider);

    // Track visited pages for stats
    _visitedPages.add(currentPage);

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
                            onPressed: () => _toggleBookmark(currentPage, riwayaId, isBookmarked),
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
                        icon: Icons.bookmark_outline,
                        label: 'العلامة',
                        onTap: _goToBookmark,
                      ),
                      _BottomAction(
                        icon: Icons.bar_chart_rounded,
                        label: 'إحصائيات',
                        onTap: () => context.push('/stats'),
                      ),
                      _BottomAction(
                        icon: Icons.auto_stories_outlined,
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

  void _toggleBookmark(int currentPage, int riwayaId, bool isBookmarked) {
    if (isBookmarked) {
      ref.read(bookmarkNotifierProvider.notifier).clearBookmark();
    } else {
      ref.read(bookmarkNotifierProvider.notifier).setBookmark(
            pageNumber: currentPage,
            riwayaId: riwayaId,
          );
    }
  }

  void _goToBookmark() {
    final bookmark = ref.read(bookmarkNotifierProvider).valueOrNull;
    if (bookmark != null) {
      ref.read(currentPageProvider.notifier).setPage(bookmark.pageNumber);
    }
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
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

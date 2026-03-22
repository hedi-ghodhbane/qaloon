import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/providers/bookmark_provider.dart';
import '../../core/providers/db_provider.dart';
import '../../core/providers/reader_providers.dart';
import '../../core/providers/stats_providers.dart';
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

  // Session tracking — page counts as "read" after 20s dwell time.
  static const _dwellSeconds = 20;
  final Set<int> _readPages = {};
  int? _sessionStartPage;
  int _currentTrackedPage = 0;
  Timer? _dwellTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    final startPage = ref.read(currentPageProvider);
    _sessionStartPage = startPage;
    _currentTrackedPage = startPage;
    _startDwellTimer();

    // Listen for page changes from the provider (not in build).
    ref.listenManual(currentPageProvider, (prev, next) {
      if (next != _currentTrackedPage) {
        _onPageChanged(next);
      }
    });
  }

  @override
  void dispose() {
    _dwellTimer?.cancel();
    _saveSession();
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _dwellTimer?.cancel();
      _saveSession();
    } else if (state == AppLifecycleState.resumed) {
      _startDwellTimer();
    }
  }

  void _startDwellTimer() {
    _dwellTimer?.cancel();
    _dwellTimer = Timer(Duration(seconds: _dwellSeconds), () {
      if (_currentTrackedPage > 0) {
        _readPages.add(_currentTrackedPage);
        debugPrint('[READ] Page $_currentTrackedPage marked as read');
        // Save immediately so stats update in real-time.
        _saveSession();
      }
    });
  }

  void _onPageChanged(int newPage) {
    // Cancel old timer — page wasn't read long enough.
    _dwellTimer?.cancel();
    _currentTrackedPage = newPage;
    _startDwellTimer();
  }

  void _saveSession() {
    if (_readPages.isEmpty || _sessionStartPage == null) return;
    final riwayaId = ref.read(currentRiwayaIdProvider);
    final endPage = ref.read(currentPageProvider);
    final pagesRead = _readPages.length;

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
    _readPages.clear();
    _sessionStartPage = ref.read(currentPageProvider);
    // Invalidate stats so they refresh if the stats screen is open.
    ref.invalidate(readingStatsProvider(riwayaId));
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
      body: Stack(
          children: [
            MushafPageView(
              onBackgroundTap: _toggleOverlay,
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
                  child: _buildBottomBar(context),
                ),
              ),
            ],
          ],
        ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final mode = ref.watch(readerModeProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Bookmark
        _BottomAction(
          icon: Icons.bookmark_outline,
          label: 'العلامة',
          onTap: _goToBookmark,
        ),
        // Hide all page
        _BottomAction(
          icon: Icons.visibility_off_outlined,
          label: 'إخفاء الكل',
          onTap: () {
            ref.read(readerModeProvider.notifier).state = ReaderMode.hidePage;
            ref.read(readerActionProvider.notifier).state =
                ReaderAction.hideAll;
          },
        ),
        // Show all
        _BottomAction(
          icon: Icons.visibility,
          label: 'إظهار الكل',
          onTap: () {
            ref.read(readerActionProvider.notifier).state =
                ReaderAction.showAll;
            ref.read(readerModeProvider.notifier).state = ReaderMode.normal;
          },
        ),
        // Select mode / hide selected
        _BottomAction(
          icon: mode == ReaderMode.select
              ? Icons.check_circle_outline
              : Icons.select_all,
          label: mode == ReaderMode.select ? 'إخفاء المحدد' : 'تحديد',
          onTap: () {
            if (mode == ReaderMode.select) {
              ref.read(readerActionProvider.notifier).state =
                  ReaderAction.hideSelected;
              ref.read(readerModeProvider.notifier).state = ReaderMode.normal;
            } else {
              ref.read(readerModeProvider.notifier).state = ReaderMode.select;
            }
          },
        ),
        // Stats
        _BottomAction(
          icon: Icons.bar_chart_rounded,
          label: 'إحصائيات',
          onTap: () => context.push('/stats'),
        ),
      ],
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

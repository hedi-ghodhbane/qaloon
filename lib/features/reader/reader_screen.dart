import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/providers/bookmark_provider.dart';
import '../../core/providers/db_provider.dart';
import '../../core/providers/reader_providers.dart';
import '../../core/providers/riwaya_providers.dart';
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'صفحة $currentPage',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildDownloadChip(),
                        ],
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
                          IconButton(
                            icon: const Icon(Icons.settings_outlined, color: Colors.white),
                            onPressed: () => context.push('/settings'),
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

  bool _tarteelExpanded = false;

  Widget _buildBottomBar(BuildContext context) {
    final mode = ref.watch(readerModeProvider);

    if (_tarteelExpanded) {
      return _buildTarteelMenu(mode);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _BottomAction(
          icon: Icons.bookmark_outline,
          label: 'العلامة',
          onTap: _goToBookmark,
        ),
        _BottomAction(
          icon: Icons.auto_fix_high,
          label: 'تسميع',
          onTap: () => setState(() => _tarteelExpanded = true),
        ),
        _BottomAction(
          icon: Icons.bar_chart_rounded,
          label: 'إحصائيات',
          onTap: () => context.push('/stats'),
        ),
      ],
    );
  }

  Widget _buildTarteelMenu(ReaderMode mode) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tarteel tools — 2 rows in a pill
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Hide all / Show all
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TarteelChip(
                    icon: Icons.visibility_off,
                    label: 'إخفاء الكل',
                    onTap: () {
                      ref.read(readerModeProvider.notifier).state =
                          ReaderMode.hidePage;
                      ref.read(readerActionProvider.notifier).state =
                          ReaderAction.hideAll;
                    },
                  ),
                  const SizedBox(width: 8),
                  _TarteelChip(
                    icon: Icons.visibility,
                    label: 'إظهار الكل',
                    onTap: () {
                      ref.read(readerActionProvider.notifier).state =
                          ReaderAction.showAll;
                      ref.read(readerModeProvider.notifier).state =
                          ReaderMode.normal;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Row 2: Show next / Hide next / Select
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TarteelChip(
                    icon: Icons.skip_next,
                    label: 'إظهار التالية',
                    onTap: () {
                      ref.read(readerActionProvider.notifier).state =
                          ReaderAction.showNext;
                    },
                  ),
                  const SizedBox(width: 8),
                  _TarteelChip(
                    icon: Icons.skip_previous,
                    label: 'إخفاء التالية',
                    onTap: () {
                      ref.read(readerActionProvider.notifier).state =
                          ReaderAction.hideNext;
                    },
                  ),
                  const SizedBox(width: 8),
                  _TarteelChip(
                    icon: mode == ReaderMode.select
                        ? Icons.check_circle_outline
                        : Icons.select_all,
                    label:
                        mode == ReaderMode.select ? 'إخفاء المحدد' : 'تحديد',
                    active: mode == ReaderMode.select,
                    onTap: () {
                      if (mode == ReaderMode.select) {
                        ref.read(readerActionProvider.notifier).state =
                            ReaderAction.hideSelected;
                        ref.read(readerModeProvider.notifier).state =
                            ReaderMode.normal;
                        setState(() => _tarteelExpanded = false);
                      } else {
                        ref.read(readerModeProvider.notifier).state =
                            ReaderMode.select;
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        // Close button
        GestureDetector(
          onTap: () => setState(() => _tarteelExpanded = false),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.keyboard_arrow_down,
                color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadChip() {
    final dlState = ref.watch(pageDownloadProvider);
    if (dlState.isComplete) return const SizedBox.shrink();
    if (dlState.error != null) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () => ref.read(pageDownloadProvider.notifier).retry(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, color: Colors.white, size: 12),
                SizedBox(width: 4),
                Text('إعادة', style: TextStyle(color: Colors.white, fontSize: 10)),
              ],
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                value: dlState.progress,
                strokeWidth: 1.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${(dlState.progress * 100).toInt()}%',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
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

class _TarteelChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _TarteelChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withValues(alpha: 0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: active
              ? null
              : Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
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
      ),
    );
  }
}

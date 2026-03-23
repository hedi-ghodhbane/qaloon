import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../db/app_database.dart';
import '../../features/riwaya/download_service.dart';
import 'db_provider.dart';

final riwayaListProvider = StreamProvider<List<RiwayaTableData>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.riwayaDao.watchAllRiwayas();
});

/// Tracks the download state: progress 0.0–1.0, succeeded/failed counts.
final pageDownloadProvider =
    StateNotifierProvider<PageDownloadNotifier, PageDownloadState>(
  (ref) => PageDownloadNotifier(ref),
);

class PageDownloadState {
  final double progress; // 0.0–1.0
  final bool isDownloading;
  final bool isComplete;
  final int lastDownloadedPage;
  final String? error;

  const PageDownloadState({
    this.progress = 0.0,
    this.isDownloading = false,
    this.isComplete = false,
    this.lastDownloadedPage = kBundledPages,
    this.error,
  });

  PageDownloadState copyWith({
    double? progress,
    bool? isDownloading,
    bool? isComplete,
    int? lastDownloadedPage,
    String? error,
  }) =>
      PageDownloadState(
        progress: progress ?? this.progress,
        isDownloading: isDownloading ?? this.isDownloading,
        isComplete: isComplete ?? this.isComplete,
        lastDownloadedPage: lastDownloadedPage ?? this.lastDownloadedPage,
        error: error,
      );
}

class PageDownloadNotifier extends StateNotifier<PageDownloadState> {
  final Ref _ref;
  final DownloadService _service = DownloadService();

  PageDownloadNotifier(this._ref) : super(const PageDownloadState()) {
    _checkAndStart();
  }

  Future<void> _checkAndStart() async {
    final alreadyDone = await _service.isFullyDownloaded(RiwayaKeys.qaloun);
    if (alreadyDone) {
      state = state.copyWith(
        isComplete: true,
        progress: 1.0,
        lastDownloadedPage: kTotalPages,
      );
      return;
    }
    // Auto-start download.
    startDownload();
  }

  Future<void> startDownload() async {
    if (state.isDownloading) return;
    state = state.copyWith(isDownloading: true, error: null);

    try {
      await _service.downloadRemainingPages(
        riwayaKey: RiwayaKeys.qaloun,
        onProgress: (succeeded, failed, total) {
          final progress = (succeeded + failed) / total;
          final lastPage = kBundledPages + succeeded;
          state = state.copyWith(
            progress: progress,
            lastDownloadedPage: lastPage,
          );
        },
      );

      final actualCount =
          await _service.downloadedPageCount(RiwayaKeys.qaloun);
      final allDone = actualCount >= (kTotalPages - kBundledPages);
      state = state.copyWith(
        isDownloading: false,
        isComplete: allDone,
        progress: allDone ? 1.0 : actualCount / (kTotalPages - kBundledPages),
        lastDownloadedPage: allDone ? kTotalPages : kBundledPages + actualCount,
        error: allDone ? null : 'تم تحميل $actualCount صفحة فقط',
      );
      debugPrint('[DOWNLOAD] Done — $actualCount pages.');
      if (allDone) {
        final db = _ref.read(appDatabaseProvider);
        db.riwayaDao.markDownloaded(kQalounRiwayaId);
      }
    } catch (e) {
      debugPrint('[DOWNLOAD] Error: $e');
      state = state.copyWith(
        isDownloading: false,
        error: '$e',
      );
    }
  }

  void retry() {
    state = state.copyWith(error: null);
    startDownload();
  }
}

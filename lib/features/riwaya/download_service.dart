import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants.dart';

class DownloadService {
  bool _initialized = false;

  /// Initialize the background downloader. Call once at app start.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    // Configure for parallel downloads.
    await FileDownloader().configure(
      globalConfig: [
        (Config.holdingQueue, (null, 15, null)),
      ],
    );
    debugPrint('[DOWNLOAD] Background downloader initialized');
  }

  /// Returns the local directory for a riwaya's downloaded pages.
  Future<Directory> riwayaDir(String riwayaKey) async {
    final dir = await getApplicationDocumentsDirectory();
    final rDir = Directory('${dir.path}/riwaya_$riwayaKey');
    if (!rDir.existsSync()) rDir.createSync(recursive: true);
    return rDir;
  }

  /// Whether all non-bundled pages have been downloaded.
  Future<bool> isFullyDownloaded(String riwayaKey) async {
    final dir = await riwayaDir(riwayaKey);
    return File('${dir.path}/$kTotalPages.png').existsSync();
  }

  /// How many pages are downloaded (excluding bundled ones).
  Future<int> downloadedPageCount(String riwayaKey) async {
    final dir = await riwayaDir(riwayaKey);
    if (!dir.existsSync()) return 0;
    return dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.png') && f.lengthSync() > 0)
        .length;
  }

  /// Downloads remaining pages using background_downloader batch API.
  /// Continues even when app goes to background.
  /// [onProgress] is called with (succeeded, failed, total).
  Future<void> downloadRemainingPages({
    required String riwayaKey,
    int startPage = kBundledPages + 1,
    void Function(int succeeded, int failed, int total)? onProgress,
  }) async {
    await init();
    final dir = await riwayaDir(riwayaKey);

    // Check if already fully downloaded.
    if (File('${dir.path}/$kTotalPages.png').existsSync()) {
      onProgress?.call(kTotalPages - kBundledPages, 0, kTotalPages - kBundledPages);
      return;
    }

    // Build list of tasks for pages that still need downloading.
    final tasks = <DownloadTask>[];
    for (int p = startPage; p <= kTotalPages; p++) {
      final file = File('${dir.path}/$p.png');
      if (!file.existsSync() || file.lengthSync() == 0) {
        final paddedPage = p.toString().padLeft(3, '0');
        tasks.add(DownloadTask(
          url: '$kQalounPagesBaseUrl/page$paddedPage.png',
          filename: '$p.png',
          directory: 'riwaya_$riwayaKey',
          baseDirectory: BaseDirectory.applicationDocuments,
          updates: Updates.status,
          retries: 3,
          group: 'qaloun_pages',
        ));
      }
    }

    if (tasks.isEmpty) {
      onProgress?.call(kTotalPages - kBundledPages, 0, kTotalPages - kBundledPages);
      return;
    }

    final total = tasks.length;
    debugPrint('[DOWNLOAD] $total pages to download via background_downloader');

    final result = await FileDownloader().downloadBatch(
      tasks,
      batchProgressCallback: (succeeded, failed) {
        onProgress?.call(succeeded, failed, total);
        if ((succeeded + failed) % 50 == 0) {
          debugPrint('[DOWNLOAD] $succeeded/$total done, $failed failed');
        }
      },
    );

    final succeeded = result.numSucceeded;
    final failed = result.numFailed;
    debugPrint('[DOWNLOAD] Batch complete: $succeeded succeeded, $failed failed');

    if (failed > 0) {
      debugPrint('[DOWNLOAD] Retrying $failed failed pages...');
      // Clean up empty files from failed downloads.
      for (int p = startPage; p <= kTotalPages; p++) {
        final file = File('${dir.path}/$p.png');
        if (file.existsSync() && file.lengthSync() == 0) {
          file.deleteSync();
        }
      }
    }
  }

  /// Delete all downloaded pages for a riwaya.
  Future<void> deleteRiwaya(String riwayaKey) async {
    final dir = await riwayaDir(riwayaKey);
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }
}

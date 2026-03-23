import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants.dart';

/// Number of concurrent page downloads.
const _kConcurrency = 10;

class DownloadService {
  final Dio _dio;

  DownloadService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
            ));

  /// Returns the local directory for a riwaya's downloaded pages.
  Future<Directory> riwayaDir(String riwayaKey) async {
    final dir = await getApplicationDocumentsDirectory();
    return Directory('${dir.path}/riwaya_$riwayaKey');
  }

  /// Whether all non-bundled pages have been downloaded.
  Future<bool> isFullyDownloaded(String riwayaKey) async {
    final dir = await riwayaDir(riwayaKey);
    if (!dir.existsSync()) return false;
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

  /// Downloads pages one-by-one from jsDelivr CDN with concurrency.
  /// Yields progress 0.0–1.0. Resumable — skips already downloaded pages.
  Stream<double> downloadRemainingPages({
    required String riwayaKey,
    int startPage = kBundledPages + 1,
  }) async* {
    final dir = await riwayaDir(riwayaKey);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    // Check if already fully downloaded.
    if (File('${dir.path}/$kTotalPages.png').existsSync()) {
      yield 1.0;
      return;
    }

    // Build list of pages that still need downloading.
    final pagesToDownload = <int>[];
    for (int p = startPage; p <= kTotalPages; p++) {
      final file = File('${dir.path}/$p.png');
      if (!file.existsSync() || file.lengthSync() == 0) {
        pagesToDownload.add(p);
      }
    }

    if (pagesToDownload.isEmpty) {
      yield 1.0;
      return;
    }

    final totalToDownload = pagesToDownload.length;
    var completed = 0;

    debugPrint('[DOWNLOAD] $totalToDownload pages to download via jsDelivr CDN');

    // Process in batches of _kConcurrency.
    for (var i = 0; i < pagesToDownload.length; i += _kConcurrency) {
      final batch = pagesToDownload.skip(i).take(_kConcurrency);
      final futures = batch.map((page) => _downloadPage(page, dir.path));
      await Future.wait(futures);

      completed += batch.length;
      final progress = completed / totalToDownload;
      yield progress;

      if (completed % 50 == 0 || completed == totalToDownload) {
        debugPrint('[DOWNLOAD] $completed/$totalToDownload pages done');
      }
    }

    yield 1.0;
    debugPrint('[DOWNLOAD] Done — $totalToDownload pages downloaded.');
  }

  /// Download a single page image from jsDelivr CDN.
  Future<void> _downloadPage(int pageNum, String outputDir) async {
    final paddedPage = pageNum.toString().padLeft(3, '0');
    final url = '$kQalounPagesBaseUrl/page$paddedPage.png';
    final filePath = '$outputDir/$pageNum.png';

    try {
      await _dio.download(url, filePath);
    } on DioException catch (e) {
      debugPrint('[DOWNLOAD] Failed page $pageNum: $e');
      // Don't rethrow — skip failed pages, they'll be retried next time.
      final file = File(filePath);
      if (file.existsSync() && file.lengthSync() == 0) {
        file.deleteSync();
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

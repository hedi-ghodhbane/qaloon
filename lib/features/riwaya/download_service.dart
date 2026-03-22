import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants.dart';

class DownloadService {
  final Dio _dio;

  DownloadService({Dio? dio}) : _dio = dio ?? Dio();

  /// Returns the local directory for a riwaya's downloaded pages.
  Future<Directory> riwayaDir(String riwayaKey) async {
    final dir = await getApplicationDocumentsDirectory();
    return Directory('${dir.path}/riwaya_$riwayaKey');
  }

  /// Whether all non-bundled pages have been downloaded.
  Future<bool> isFullyDownloaded(String riwayaKey) async {
    final dir = await riwayaDir(riwayaKey);
    if (!dir.existsSync()) return false;
    // Check if last page exists.
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

  /// Downloads pages [startPage] to [kTotalPages], yielding progress 0.0–1.0.
  /// Pages 1–[kBundledPages] are bundled in the APK — only download the rest.
  Stream<double> downloadRemainingPages({
    required String riwayaKey,
    int startPage = kBundledPages + 1,
  }) async* {
    final dir = await riwayaDir(riwayaKey);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final totalToDownload = kTotalPages - startPage + 1;
    var downloaded = 0;

    for (int page = startPage; page <= kTotalPages; page++) {
      final filePath = '${dir.path}/$page.png';
      final file = File(filePath);

      // Skip already downloaded pages (resume support).
      if (file.existsSync() && file.lengthSync() > 0) {
        downloaded++;
        yield downloaded / totalToDownload;
        continue;
      }

      final paddedPage = page.toString().padLeft(3, '0');
      final url = '$kQalounPagesBaseUrl/page$paddedPage.png';
      try {
        await _dio.download(url, filePath);
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          await _dio.download(url, filePath);
        } else {
          debugPrint('[DOWNLOAD] Failed page $page: $e');
          rethrow;
        }
      }

      downloaded++;
      yield downloaded / totalToDownload;
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

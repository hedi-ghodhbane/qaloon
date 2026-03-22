import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants.dart';

/// ZIP URL for the entire GoldenQuranRes repo (contains all Qaloun images).
const _kZipUrl =
    'https://github.com/salemoh/GoldenQuranRes/archive/refs/heads/master.zip';

/// Path inside the ZIP where Qaloun 1260 images live.
const _kZipImagePrefix = 'GoldenQuranRes-master/images/Qaloon_new_1260/';

class DownloadService {
  final Dio _dio;

  DownloadService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(minutes: 10),
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

  /// Downloads the full repo ZIP then extracts only the Qaloun page images.
  /// Yields progress: 0.0–0.7 for download, 0.7–1.0 for extraction.
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

    // --- Phase 1: Download ZIP (0.0–0.7) ---
    final tmpDir = await getTemporaryDirectory();
    final zipPath = '${tmpDir.path}/qaloun_pages.zip';
    final zipFile = File(zipPath);

    debugPrint('[DOWNLOAD] Downloading ZIP from $_kZipUrl');

    await _dio.download(
      _kZipUrl,
      zipPath,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          // Map download progress to 0.0–0.7
        }
      },
    );

    // Emit 0.7 after download completes.
    yield 0.7;
    debugPrint('[DOWNLOAD] ZIP downloaded: ${zipFile.lengthSync()} bytes');

    // --- Phase 2: Extract images (0.7–1.0) ---
    yield* _extractZip(zipPath, dir.path, startPage);

    // Cleanup ZIP.
    try {
      zipFile.deleteSync();
    } catch (_) {}

    yield 1.0;
    debugPrint('[DOWNLOAD] Extraction complete.');
  }

  /// Extract page PNGs from the ZIP in an isolate to avoid blocking the UI.
  Stream<double> _extractZip(
    String zipPath,
    String outputDir,
    int startPage,
  ) async* {
    final bytes = await File(zipPath).readAsBytes();

    // Decode ZIP in an isolate for performance.
    final archive = await compute(_decodeZip, bytes);

    // Filter to only the Qaloun page images we need.
    final pageFiles = archive.files.where((f) {
      if (f.isFile && f.name.startsWith(_kZipImagePrefix)) {
        final fileName = f.name.substring(_kZipImagePrefix.length);
        return fileName.startsWith('page') && fileName.endsWith('.png');
      }
      return false;
    }).toList();

    debugPrint('[DOWNLOAD] Found ${pageFiles.length} page images in ZIP');

    final total = pageFiles.length;
    var extracted = 0;

    for (final file in pageFiles) {
      final fileName = file.name.substring(_kZipImagePrefix.length);
      // Convert pageNNN.png → N.png (e.g. page042.png → 42.png)
      final match = RegExp(r'page(\d+)\.png').firstMatch(fileName);
      if (match == null) continue;

      final pageNum = int.parse(match.group(1)!);

      // Skip bundled pages (already in assets).
      if (pageNum < startPage) {
        extracted++;
        continue;
      }

      final outFile = File('$outputDir/$pageNum.png');
      if (!outFile.existsSync() || outFile.lengthSync() == 0) {
        outFile.writeAsBytesSync(file.content as List<int>);
      }

      extracted++;
      // Map extraction progress to 0.7–1.0
      yield 0.7 + (extracted / total) * 0.3;
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

/// Top-level function for compute() — decodes ZIP bytes in an isolate.
Archive _decodeZip(Uint8List bytes) {
  return ZipDecoder().decodeBytes(bytes);
}

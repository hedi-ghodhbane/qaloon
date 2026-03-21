import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants.dart';

class DownloadService {
  final Dio _dio;

  DownloadService({Dio? dio}) : _dio = dio ?? Dio();

  /// Base URL pattern for page images per riwaya.
  static const _baseUrls = {
    'qaloun':
        'https://raw.githubusercontent.com/maknon/Quran/master/pages-qalon',
    'warsh':
        'https://raw.githubusercontent.com/maknon/Quran/master/pages-warsh',
    'hafs':
        'https://raw.githubusercontent.com/maknon/Quran/master/pages-hafs',
  };

  /// Downloads all pages for a riwaya, yielding progress 0.0–1.0.
  Stream<double> downloadRiwaya(String riwayaKey) async* {
    final baseUrl = _baseUrls[riwayaKey];
    if (baseUrl == null) throw ArgumentError('Unknown riwaya: $riwayaKey');

    final dir = await getApplicationDocumentsDirectory();
    final riwayaDir = Directory('${dir.path}/riwaya_$riwayaKey');
    if (!riwayaDir.existsSync()) {
      riwayaDir.createSync(recursive: true);
    }

    for (int page = 1; page <= kTotalPages; page++) {
      final filePath = '${riwayaDir.path}/$page.png';
      final file = File(filePath);

      // Skip already downloaded pages (resume support).
      if (file.existsSync() && file.lengthSync() > 0) {
        yield page / kTotalPages;
        continue;
      }

      final url = '$baseUrl/$page.png';
      try {
        await _dio.download(url, filePath);
      } on DioException catch (e) {
        // Retry once on failure.
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          await _dio.download(url, filePath);
        } else {
          rethrow;
        }
      }

      yield page / kTotalPages;
    }
  }

  /// Check how many pages are already downloaded for a riwaya.
  Future<int> downloadedPageCount(String riwayaKey) async {
    final dir = await getApplicationDocumentsDirectory();
    final riwayaDir = Directory('${dir.path}/riwaya_$riwayaKey');
    if (!riwayaDir.existsSync()) return 0;

    return riwayaDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.png') && f.lengthSync() > 0)
        .length;
  }

  /// Delete all downloaded pages for a riwaya.
  Future<void> deleteRiwaya(String riwayaKey) async {
    final dir = await getApplicationDocumentsDirectory();
    final riwayaDir = Directory('${dir.path}/riwaya_$riwayaKey');
    if (riwayaDir.existsSync()) {
      await riwayaDir.delete(recursive: true);
    }
  }
}

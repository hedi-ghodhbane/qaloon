import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/app_database.dart';
import 'db_provider.dart';

final riwayaListProvider = StreamProvider<List<RiwayaTableData>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.riwayaDao.watchAllRiwayas();
});

final activeDownloadProvider =
    StateNotifierProvider<ActiveDownloadNotifier, int?>(
  (ref) => ActiveDownloadNotifier(),
);

class ActiveDownloadNotifier extends StateNotifier<int?> {
  ActiveDownloadNotifier() : super(null);

  void setDownloading(int riwayaId) => state = riwayaId;
  void clearDownloading() => state = null;
}

final downloadProgressProvider =
    StateNotifierProvider<DownloadProgressNotifier, double>(
  (ref) => DownloadProgressNotifier(),
);

class DownloadProgressNotifier extends StateNotifier<double> {
  DownloadProgressNotifier() : super(0.0);

  void update(double progress) => state = progress;
  void reset() => state = 0.0;
}

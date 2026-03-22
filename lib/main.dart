import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers/db_provider.dart';
import 'core/providers/reader_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Pre-load bookmark so the reader starts at the right page (no glitch).
  final container = ProviderContainer();
  final db = container.read(appDatabaseProvider);
  final bookmark = await db.bookmarkDao.getBookmark();
  if (bookmark != null) {
    container.read(currentPageProvider.notifier).setPage(bookmark.pageNumber);
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const QuranMushafApp(),
    ),
  );
}

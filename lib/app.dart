import 'package:flutter/material.dart';
import 'core/router.dart';
import 'shared/theme/app_theme.dart';

class QuranMushafApp extends StatelessWidget {
  const QuranMushafApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Qaloon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
      locale: const Locale('ar'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

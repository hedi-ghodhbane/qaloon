import 'package:go_router/go_router.dart';
import '../features/reader/reader_screen.dart';
import '../features/navigation/navigation_screen.dart';
import '../features/stats/stats_screen.dart';
import '../features/riwaya/riwaya_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ReaderScreen(),
    ),
    GoRoute(
      path: '/navigation',
      builder: (context, state) => const NavigationScreen(),
    ),
    GoRoute(
      path: '/stats',
      builder: (context, state) => const StatsScreen(),
    ),
    GoRoute(
      path: '/riwaya',
      builder: (context, state) => const RiwayaScreen(),
    ),
  ],
);

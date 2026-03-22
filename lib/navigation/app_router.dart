import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/layout_page.dart';
import '../pages/profile_page.dart';
import '../pages/home_tab.dart';
import '../pages/stats_tab.dart';
import '../pages/workout_tab.dart';

class AppRouter {
  AppRouter._();
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static const String home = '/home';
  static const String stats = '/stats';
  static const String workout = '/workout';
  static const String profile = '/profile';

  static final GoRouter config = GoRouter(
    initialLocation: home,
    navigatorKey: _rootNavigatorKey,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return LayoutPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: home,
                builder: (context, state) => const HomeTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: stats,
                builder: (context, state) => const StatsTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: workout,
                builder: (context, state) => const WorkoutTab(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: profile,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}
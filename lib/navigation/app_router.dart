import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/layout_page.dart';
import '../pages/profile_page.dart';
import '../pages/home_tab.dart';
import '../pages/stats_tab.dart';
import '../pages/workout_tab.dart';
import '../pages/edit_profile_page.dart';
import '../pages/settings_page.dart';
import '../pages/notifications_page.dart';

class AppRouter {
  AppRouter._();
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static const String home = '/home';
  static const String stats = '/stats';
  static const String workout = '/workout';
  static const String profile = '/profile';
  static const String editProfile = '/editProfile';
  static const String settingsPage = '/settingsPage';
  static const String notificationsPage = '/notifications';

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

      GoRoute(
        path: editProfile,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final String avatar = state.extra as String? ?? 'lib/img/Avatar.svg';
          return EditProfile(avatarPath: avatar);
        },
      ),

      GoRoute(
        path: settingsPage,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsPage(),
      ),

      GoRoute(
        path: notificationsPage,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsPage(),
      ),
    ],
  );
}
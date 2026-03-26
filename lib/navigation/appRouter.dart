import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/layoutForTabs.dart';
import '../pages/pageProfile.dart';
import '../pages/tabHome.dart';
import '../pages/tabStats.dart';
import '../pages/tabWorkout.dart';
import '../pages/pageEditProfile.dart';
import '../pages/pageSettings.dart';
import '../pages/pageNotifications.dart';

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
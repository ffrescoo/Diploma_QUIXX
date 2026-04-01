import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/glass_theme.dart';
import '../navigation/appRouter.dart';

class AppBottomBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppBottomBar({super.key, required this.navigationShell});

  static const List<GlassBottomBarTab> tabs = [
    GlassBottomBarTab(
      label: 'Home',
      icon: ImageIcon(
        AssetImage('assets/images/home.png'),
        size: 20,
      ),
    ),
    GlassBottomBarTab(
      label: 'Stats',
      icon: ImageIcon(
        AssetImage('assets/images/graph.png'),
        size: 20,
      ),
    ),
    GlassBottomBarTab(
      label: 'Workout',
      icon: ImageIcon(
        AssetImage('assets/images/dumbell.png'),
        size: 20,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final extraButton = GlassBottomBarExtraButton(
      size: 60,
      icon: ImageIcon(
        AssetImage('assets/images/ai.png'),
        size: 35,
      ),
      label: 'Profile',
      onTap: () {
        context.push(AppRouter.loginPage);
      },
    );

    return GlassBottomBar(
      barHeight: 60,
      barBorderRadius: 35,
      horizontalPadding: 20,
      verticalPadding: 20,
      spacing: 10,
      indicatorColor: Colors.white24,
      quality: ShowcaseGlassTheme.premiumQuality,
      glassSettings: ShowcaseGlassTheme.profileButtonBar,
      extraButton: extraButton,
      tabs: tabs,
      selectedIndex: navigationShell.currentIndex,
      onTabSelected: (index) {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
    );
  }
}
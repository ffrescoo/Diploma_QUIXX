import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/glass_theme.dart';

class AppBottomBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppBottomBar({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBottomBar(
      verticalPadding: 30,
      horizontalPadding: 20,
      indicatorColor: Colors.white24,
      quality: ShowcaseGlassTheme.premiumQuality,
      glassSettings: ShowcaseGlassTheme.profileButton,
      extraButton: GlassBottomBarExtraButton(

        icon: Icon(Icons.interests_outlined),
        label: 'Profile',
        onTap: () {},
      ),

      tabs: [
        GlassBottomBarTab(
          label: 'Home',
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
        ),
        GlassBottomBarTab(
          label: 'Stats',
          icon: Icon(Icons.insert_chart_outlined),
          activeIcon: Icon(Icons.insert_chart),
        ),
        GlassBottomBarTab(
          label: 'Workout',
          icon: Icon(Icons.fitness_center_outlined),
          activeIcon: Icon(Icons.fitness_center),
        ),
      ],
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
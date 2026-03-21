import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/showcase_glass_theme.dart';
import '../navigation/app_router.dart';

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

        icon: Icons.person,
        label: 'Profile',
        onTap: () => context.push(AppRouter.profile),
      ),

      tabs: [
        GlassBottomBarTab(label: 'Home', icon: Icons.home_outlined, selectedIcon: Icons.home),
        GlassBottomBarTab(label: 'Stats', icon: Icons.insert_chart_outlined, selectedIcon: Icons.insert_chart),
        GlassBottomBarTab(label: 'Workout', icon: Icons.fitness_center, selectedIcon: Icons.fitness_center),
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
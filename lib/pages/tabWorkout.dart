import 'package:flutter/material.dart';
import '../widgets/appDefaultLayout.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/glass_theme.dart';

class WorkoutTab extends StatelessWidget {
  const WorkoutTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDefaultLayout(
      body: Column(
        spacing: 15,
        children: [
          GlassContainer(
            width: double.infinity,
            shape: const LiquidRoundedSuperellipse(borderRadius: 27),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Row(
                children: [
                  ImageIcon(
                    AssetImage('assets/images/plus.png'),
                    size: 25,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Start new training',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          GlassContainer(
            width: double.infinity,
            shape: const LiquidRoundedSuperellipse(borderRadius: 27),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(
                    'Programs',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Row(
                    spacing: 15,
                    children: [
                      Expanded(
                        child: GlassButton.custom(
                          width: double.infinity,
                          height: 70,
                          settings: ShowcaseGlassTheme.profileButtonWhiteLight,
                          shape: const LiquidRoundedSuperellipse(
                            borderRadius: 13,
                          ),
                          onTap: () {},
                          child: const Text(
                            'Create new',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: GlassButton.custom(
                          width: double.infinity,
                          height: 70,
                          settings: ShowcaseGlassTheme.profileButtonWhiteLight,
                          shape: const LiquidRoundedSuperellipse(
                            borderRadius: 13,
                          ),
                          onTap: () {},
                          child: const Text(
                            'Search',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          GlassContainer(
            width: double.infinity,
            shape: const LiquidRoundedSuperellipse(borderRadius: 27),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 15,
                children: [
                  Text(
                    'My programs',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  programsSection(title: 'Back + Biceps'),
                  programsSection(title: 'Chest + Triceps'),
                  programsSection(title: 'Legs + Abs'),
                ],
              ),
            ),
          ),

          GlassContainer(
            width: double.infinity,
            shape: const LiquidRoundedSuperellipse(borderRadius: 27),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    'No training started',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      top: const SizedBox(height: 0),
      topSpacing: 15,
    );
  }

  Widget programsSection({required String title}) {
    return GlassContainer(
      width: double.infinity,
      shape: const LiquidRoundedSuperellipse(borderRadius: 13),
      settings: ShowcaseGlassTheme.profileButtonWhiteLight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ImageIcon(
                  AssetImage('assets/images/more.png'),
                  size: 25,
                  color: Colors.white,
                ),
              ],
            ),

            GlassButton.custom(
              width: double.infinity,
              height: 50,
              settings: ShowcaseGlassTheme.profileButtonWhite,
              shape: const LiquidRoundedSuperellipse(borderRadius: 15),
              onTap: () {},
              child: const Text(
                'Start program',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

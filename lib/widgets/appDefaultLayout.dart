import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/glass_theme.dart';
import '../widgets/appBackground.dart';

class AppDefaultLayout extends StatelessWidget {
  final Widget body;
  final Widget top;
  final double topSpacing;

  const AppDefaultLayout({
    super.key,
    required this.body,
    required this.top,
    this.topSpacing = 64,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child:
     SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: topSpacing),
                      AdaptiveLiquidGlassLayer(
                        settings: ShowcaseGlassTheme.profilePanelDark,
                        quality: ShowcaseGlassTheme.standardQuality,
                        child: body,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: AdaptiveLiquidGlassLayer(
                  quality: ShowcaseGlassTheme.premiumQuality,
                  settings: ShowcaseGlassTheme.profileButtonTopBar,
                  child: top,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
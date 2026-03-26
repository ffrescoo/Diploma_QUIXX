import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/glass_theme.dart';

class AppDefaultLayout extends StatelessWidget {
  final Widget body;
  final Widget top;

  const AppDefaultLayout({super.key, required this.body, required this.top});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090012),
      body: SafeArea(
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
                      const SizedBox(height: 80),
                      AdaptiveLiquidGlassLayer(
                        settings: ShowcaseGlassTheme.profileButtonBig,
                        quality: ShowcaseGlassTheme.standardQuality,
                        child: body,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: AdaptiveLiquidGlassLayer(
                  quality: ShowcaseGlassTheme.premiumQuality,
                  settings: ShowcaseGlassTheme.profileButton,
                  child: top,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
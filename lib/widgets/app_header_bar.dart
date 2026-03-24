import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/showcase_glass_theme.dart';
import 'package:go_router/go_router.dart';

class AppHeaderBar extends StatelessWidget {

  final String title;
  final String secondButtonTitle;
  final double secondButtonWidth;

  const AppHeaderBar({
    super.key,
    required this.title,
    required this.secondButtonTitle,
    this.secondButtonWidth = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveLiquidGlassLayer(
      quality: ShowcaseGlassTheme.premiumQuality,
      settings: ShowcaseGlassTheme.profileButton,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: GlassButton(
              icon: const Icon(Icons.arrow_back),
              iconSize: 25,
              width: 45,
              height: 45,
              onTap: () => context.pop(),
            ),
          ),

          IntrinsicWidth(
            child: GlassButton.custom(
              height: 45,
              width: double.infinity,
              shape: const LiquidRoundedSuperellipse(borderRadius: 25),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.topRight,
            child: IntrinsicWidth(
              child: GlassButton.custom(
                width: secondButtonWidth,
                height: 45,
                shape: const LiquidRoundedSuperellipse(borderRadius: 25),
                onTap: () => context.pop(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    secondButtonTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/showcase_glass_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../navigation/app_router.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: AdaptiveLiquidGlassLayer(
                quality: ShowcaseGlassTheme.premiumQuality,
                settings: ShowcaseGlassTheme.profileButton,
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     IntrinsicWidth(
                        child: GlassButton.custom(
                          width: double.infinity,
                          height: 45,
                          shape: const LiquidRoundedSuperellipse(
                            borderRadius: 25,
                          ),
                          onTap: () => context.push(AppRouter.profile),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              spacing: 8,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/Avatar.svg',
                                  width: 29,
                                  height: 29,
                                ),
                                const Text(
                                  '@NoNameUser',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    Row(
                      spacing: 9,
                        children: [
                          IntrinsicWidth(
                            child: GlassButton.custom(
                              width: double.infinity,
                              height: 45,
                              shape: const LiquidRoundedSuperellipse(
                                borderRadius: 25,
                              ),
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Row(
                                  spacing: 8,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Add post',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Icon(Icons.add, size: 24),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          GlassButton(
                            icon: Icon(Icons.notifications_rounded),
                            iconSize: 25,
                            width: 45,
                            height: 45,
                            onTap: () => context.push(AppRouter.notificationsPage),
                          ),
                        ],
                      ),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:go_router/go_router.dart';
import '../theme/showcase_glass_theme.dart';
import '../widgets/app_background.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SizedBox.expand(
        child: AppBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: GlassButton(
                  quality: ShowcaseGlassTheme.premiumQuality,
                  settings: ShowcaseGlassTheme.profileButton,
                    icon: Icons.arrow_back_ios_new,
                  iconSize: 22,
                  width: 60,
                  height: 60,
                  useOwnLayer: true,
                  onTap: () => context.pop()
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
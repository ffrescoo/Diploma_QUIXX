import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../theme/showcase_glass_theme.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedMeshGradient(
              colors: const [
                Color(0xFFCCB3D1),
                Color(0xFF4C4A6C),
                Color(0xFF22052D),
                Color(0xFF000000),
              ],
              options: AnimatedMeshGradientOptions(
                speed: 4,
                frequency: 3,
                amplitude: 15,
                grain: 0.1,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdaptiveLiquidGlassLayer(
                    quality: ShowcaseGlassTheme.premiumQuality,
                    settings: ShowcaseGlassTheme.headerButtons,
                    child: Row(
                      children: [
                        GlassButton(
                          icon: Icons.arrow_back_ios_new,
                          iconSize: 25,
                          width: 60,
                          height: 60,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 20),
                        const Text(
                          'Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  const Center(
                    child: Text(
                      "Account info",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/glass_theme.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Color> gradientColors = [
      const Color(0xFF200050),
      const Color(0x67FFFFFF),
      const Color(0xFF000000),
      const Color(0xFF06001B),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedMeshGradient(
              colors: gradientColors,
              options: AnimatedMeshGradientOptions(
                frequency: 7,
                speed: 0.5,
                amplitude: 50.0,
                grain: 0.3,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              clipBehavior: Clip.none,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: GlassContainer(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                shape: const LiquidRoundedSuperellipse(borderRadius: 20),
                settings: ShowcaseGlassTheme.profilePanelDark,
                width: double.infinity,
                child: Column(
                  spacing: 20,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    GlassFormField(
                      label: 'Username or email',
                      child: GlassTextField(
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          size: 20,
                          color: Colors.white70,
                        ),
                        settings: ShowcaseGlassTheme.profileButtonWhiteLight,
                        shape: const LiquidRoundedSuperellipse(
                          borderRadius: 15,
                        ),
                        placeholder: 'name@example.com',
                      ),
                    ),

                    GlassFormField(
                      label: 'Password',
                      errorText: null,
                      child: GlassPasswordField(
                        settings: ShowcaseGlassTheme.profileButtonWhiteLight,
                        shape: const LiquidRoundedSuperellipse(
                          borderRadius: 15,
                        ),
                        placeholder: 'password',
                      ),
                    ),

                    GlassButton.custom(
                      onTap: () {},
                      settings: ShowcaseGlassTheme.profileButtonWhite,
                      shape: const LiquidRoundedSuperellipse(borderRadius: 15),
                      width: double.infinity,
                      height: 45,
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Text.rich(
                      TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                        children: [
                          TextSpan(
                            text: "Register",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                        ],
                      ),
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
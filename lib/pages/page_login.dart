import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/glass_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLogin = true;

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> loginColors = [
      const Color(0xFF200050),
      const Color(0x67FFFFFF),
      const Color(0xFF000000),
      const Color(0xFF06001B),
    ];

    final List<Color> registerColors = [
      const Color(0xFF0051A1),
      const Color(0x67FFFFFF),
      const Color(0xFF000000),
      const Color(0xFF002751),
    ];

    final List<Color> gradientColors = _isLogin ? loginColors : registerColors;

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
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      key: ValueKey<bool>(_isLogin),
                      spacing: 20,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isLogin ? "Login" : "Register",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        if (_isLogin) ...[
                          GlassFormField(
                            label: 'Username or email',
                            child: GlassTextField(
                              prefixIcon: const Icon(Icons.person_outline, size: 20, color: Colors.white70),
                              settings: ShowcaseGlassTheme.profileButtonWhiteLight,
                              shape: const LiquidRoundedSuperellipse(borderRadius: 15),
                              placeholder: 'name@example.com',
                            ),
                          ),
                        ] else ...[
                          GlassFormField(
                            label: 'Username',
                            child: GlassTextField(
                              prefixIcon: const Icon(Icons.face_outlined, size: 20, color: Colors.white70),
                              settings: ShowcaseGlassTheme.profileButtonWhiteLight,
                              shape: const LiquidRoundedSuperellipse(borderRadius: 15),
                              placeholder: 'username',
                            ),
                          ),
                          GlassFormField(
                            label: 'Email',
                            child: GlassTextField(
                              prefixIcon: const Icon(Icons.email_outlined, size: 20, color: Colors.white70),
                              settings: ShowcaseGlassTheme.profileButtonWhiteLight,
                              shape: const LiquidRoundedSuperellipse(borderRadius: 15),
                              placeholder: 'name@example.com',
                            ),
                          ),
                        ],

                        GlassFormField(
                          label: 'Password',
                          child: GlassPasswordField(
                            settings: ShowcaseGlassTheme.profileButtonWhiteLight,
                            shape: const LiquidRoundedSuperellipse(borderRadius: 15),
                            placeholder: 'password',
                          ),
                        ),

                        if (!_isLogin)
                          GlassFormField(
                            label: 'Confirm Password',
                            child: GlassPasswordField(
                              settings: ShowcaseGlassTheme.profileButtonWhiteLight,
                              shape: const LiquidRoundedSuperellipse(borderRadius: 15),
                              placeholder: 'repeat password',
                            ),
                          ),

                        GlassButton.custom(
                          onTap: () {},
                          settings: ShowcaseGlassTheme.profileButtonWhite,
                          shape: const LiquidRoundedSuperellipse(borderRadius: 15),
                          width: double.infinity,
                          height: 45,
                          child: Text(
                            _isLogin ? 'Submit' : 'Create Account',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Text.rich(
                          TextSpan(
                            text: _isLogin ? "Don't have an account? " : "Already have an account? ",
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                            children: [
                              TextSpan(
                                text: _isLogin ? "Register" : "Login",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()..onTap = _toggleAuthMode,
                              ),
                            ],
                          ),
                        ),
                      ],
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
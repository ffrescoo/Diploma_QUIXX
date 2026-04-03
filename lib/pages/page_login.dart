import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/glass_theme.dart';

class AuthConstants {
  static const loginColors = [
    Color(0xFF200050),
    Color(0x67FFFFFF),
    Color(0xFF000000),
    Color(0xFF06001B),
  ];
  static const registerColors = [
    Color(0xFF0051A1),
    Color(0x67FFFFFF),
    Color(0xFF000000),
    Color(0xFF002751),
  ];
  static const borderRadius = LiquidRoundedSuperellipse(borderRadius: 15);
  static const containerShape = LiquidRoundedSuperellipse(borderRadius: 20);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLogin = true;

  void _toggleAuthMode() => setState(() => _isLogin = !_isLogin);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [_buildBackground(), _buildForm(context)]),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: AnimatedMeshGradient(
        colors: _isLogin
            ? AuthConstants.loginColors
            : AuthConstants.registerColors,
        options: AnimatedMeshGradientOptions(
          frequency: 7,
          speed: 0.5,
          amplitude: 50.0,
          grain: 0.3,
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: GlassContainer(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          shape: AuthConstants.containerShape,
          settings: ShowcaseGlassTheme.profilePanelDark,
          width: double.infinity,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: AdaptiveLiquidGlassLayer(
                settings: ShowcaseGlassTheme.profileButtonWhiteLight,
                child: Column(
                  key: ValueKey<bool>(_isLogin),
                  spacing: 20,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    ..._buildFields(),
                    _buildSubmitButton(),
                    _buildFooterToggle(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      _isLogin ? "Login" : "Register",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 48,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  List<Widget> _buildFields() {
    return [
      if (_isLogin)
        _customField(
          label: 'Username or email',
          icon: Icons.person_outline,
          hint: 'name@example.com',
        )
      else ...[
        _customField(
          label: 'Username',
          icon: Icons.face_outlined,
          hint: 'username',
        ),
        _customField(
          label: 'Email',
          icon: Icons.email_outlined,
          hint: 'name@example.com',
        ),
      ],

      _passwordField(label: 'Password', hint: 'password'),

      if (!_isLogin)
        _passwordField(label: 'Confirm Password', hint: 'repeat password'),
    ];
  }

  Widget _customField({
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return GlassFormField(
      label: label,
      child: GlassTextField(
        prefixIcon: Icon(icon, size: 20, color: Colors.white70),
        shape: AuthConstants.borderRadius,
        placeholder: hint,
      ),
    );
  }

  Widget _passwordField({required String label, required String hint}) {
    return GlassFormField(
      label: label,
      child: GlassPasswordField(
        shape: AuthConstants.borderRadius,
        placeholder: hint,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GlassButton.custom(
      onTap: () {},
      settings: ShowcaseGlassTheme.profileButtonWhite,
      shape: AuthConstants.borderRadius,
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
    );
  }

  Widget _buildFooterToggle() {
    return Text.rich(
      TextSpan(
        text: _isLogin
            ? "Don't have an account? "
            : "Already have an account? ",
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
    );
  }
}
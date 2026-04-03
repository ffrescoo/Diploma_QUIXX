import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    if (_isLoading) return;
    setState(() => _isLogin = !_isLogin);
  }

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
      if (!_isLogin)
        _customField(
          label: 'Username',
          icon: Icons.face_outlined,
          hint: 'username',
          controller: _usernameController,
        ),
      _customField(
        label: 'Email',
        icon: Icons.email_outlined,
        hint: 'name@example.com',
        controller: _emailController,
      ),
      _passwordField(
        label: 'Password',
        hint: 'password',
        controller: _passwordController,
      ),
      if (!_isLogin)
        _passwordField(
          label: 'Confirm Password',
          hint: 'repeat password',
          controller: _confirmPasswordController,
        ),
    ];
  }

  Widget _customField({
    required String label,
    required IconData icon,
    required String hint,
    TextEditingController? controller,
  }) {
    return GlassFormField(
      label: label,
      child: GlassTextField(
        controller: controller,
        enabled: !_isLoading,
        prefixIcon: Icon(icon, size: 20, color: Colors.white70),
        shape: AuthConstants.borderRadius,
        placeholder: hint,
      ),
    );
  }

  Widget _passwordField({
    required String label,
    required String hint,
    TextEditingController? controller,
  }) {
    return GlassFormField(
      label: label,
      child: GlassPasswordField(
        controller: controller,
        enabled: !_isLoading,
        shape: AuthConstants.borderRadius,
        placeholder: hint,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GlassButton.custom(
      onTap: _isLogin ? _login : _register,
      settings: ShowcaseGlassTheme.profileButtonWhite,
      shape: AuthConstants.borderRadius,
      width: double.infinity,
      height: 45,
      child: _isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      )
          : Text(
        _isLogin ? 'Login' : 'Create Account',
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
        text: _isLogin ? "Don't have an account? " : "Already have an account? ",
        style: const TextStyle(color: Colors.white70, fontSize: 14),
        children: [
          TextSpan(
            text: _isLogin ? "Register" : "Login",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()..onTap = _toggleAuthMode,
          ),
        ],
      ),
    );
  }

  // ==================== Validation ====================

  bool _validateFields() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty) {
      _showError('Email cannot be empty');
      return false;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      _showError('Invalid email format');
      return false;
    }

    if (password.isEmpty) {
      _showError('Password cannot be empty');
      return false;
    }

    if (!_isLogin) {
      if (_usernameController.text.trim().isEmpty) {
        _showError('Username cannot be empty');
        return false;
      }
      if (confirmPassword.isEmpty) {
        _showError('Confirm Password cannot be empty');
        return false;
      }
      if (password != confirmPassword) {
        _showError('Passwords do not match');
        return false;
      }
    }
    return true;
  }

  // ==================== Firebase Auth & Firestore ====================

  Future<void> _register() async {
    if (!_validateFields() || _isLoading) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .timeout(const Duration(seconds: 15));

      final String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 10));

      await userCredential.user!.sendEmailVerification();

      if (mounted) {
        setState(() => _isLoading = false);
        _toggleAuthMode();
        _showSuccess('Registration successful! Please check your email.');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _showError(_getFriendlyErrorMessage(e));
    } on TimeoutException {
      if (mounted) setState(() => _isLoading = false);
      _showError('Connection timed out. Check your internet.');
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _showError('An unexpected error occurred during registration.');
    }
  }

  Future<void> _login() async {
    if (!_validateFields() || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      )
          .timeout(const Duration(seconds: 15));

      if (!userCredential.user!.emailVerified) {
        if (mounted) setState(() => _isLoading = false);
        _showError('Please verify your email before logging in!');
        await FirebaseAuth.instance.signOut();
        return;
      }

      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccess('Login successful!');
        context.go('/home');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _showError(_getFriendlyErrorMessage(e));
    } on TimeoutException {
      if (mounted) setState(() => _isLoading = false);
      _showError('Connection timed out. Check your internet.');
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _showError('Incorrect email or password.');
    }
  }

  // ==================== Error Messages ====================

  String _getFriendlyErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'weak-password':
        return 'Password is too weak (minimum 6 characters).';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'internal-error':
        return 'Internal server error. Please try again later.';
      case 'channel-error':
        return 'Please fill in all fields correctly.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
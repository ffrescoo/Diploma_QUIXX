import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(const QuixxApp());
}

class QuixxApp extends StatelessWidget {
  const QuixxApp({super.key});

  @override
  Widget build(BuildContext context) {

    return GlassTheme(
      data: GlassThemeData(
        light: GlassThemeVariant(
          glowColors: GlassGlowColors(
            primary: Colors.purple.withValues(alpha: 0.4),
          ),
        ),
        dark: GlassThemeVariant(
          glowColors: GlassGlowColors(
            primary: Colors.purple.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: MaterialApp.router(
        title: 'QuixxApp',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.config,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: const Color(0xFF28004A),
          fontFamily: 'SF Pro Display',
        ),
      ),
    );
  }
}
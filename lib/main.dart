import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(const QuixxApp());
}

class QuixxApp extends StatelessWidget {
  const QuixxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuixxApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF28004A),
          brightness: Brightness.dark,
        ),
        fontFamily: 'SF Pro Display',
      ),
      home: const HomePage(),
    );
  }
}
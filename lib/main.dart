import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import '../services/user_session.dart';
import 'firebase_options.dart';
import 'navigation/appRouter.dart';
import '../services/push_notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Для роботи Firebase у фоновому ізоляті потрібна повторна ініціалізація
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Обробка фонового повідомлення: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await PushNotificationService().init();
  await UserSession.init();

  await LiquidGlassWidgets.initialize();

  runApp(const QuixxApp());
}

const glassTheme = GlassThemeData(
  light: GlassThemeVariant(
    glowColors: GlassGlowColors(
      primary: Color(0x806900FF),
    ),
  ),
  dark: GlassThemeVariant(
    glowColors: GlassGlowColors(
      primary: Color(0x806900FF),
    ),
  ),
);

class QuixxApp extends StatelessWidget {
  const QuixxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'QuixxApp',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.config,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF28004A),
        fontFamily: 'SF Pro Display',
      ),
      builder: (context, child) {
        return GlassTheme(
          data: glassTheme,
          child: child!,
        );
      },
    );
  }
}
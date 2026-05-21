import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../widgets/appDefaultLayout.dart';
import '../widgets/appBarTop.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_session.dart';
import '../services/local_storage.dart';
import '../services/database_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isNotificationsEnabled = true;
  int _selectedSegment3 = 0;
  int _selectedSegment2 = 0;
  int _selectedSegment1 = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    final weight = await LocalStorage.getWeightUnit();
    final distance = await LocalStorage.getDistanceUnit();
    final measurements = await LocalStorage.getMeasurementsUnit();
    final notifications = await LocalStorage.getNotificationsState();

    setState(() {
      _selectedSegment1 = weight;
      _selectedSegment2 = distance;
      _selectedSegment3 = measurements;
      _isNotificationsEnabled = notifications;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppDefaultLayout(
      body: Column(
        spacing: 15,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Units',
            style: TextStyle(color: Colors.white54, fontSize: 22),
          ),
          const Divider(color: Colors.grey, thickness: 0.5),
          GlassCard(
            height: 60,
            width: double.infinity,
            shape: const LiquidRoundedSuperellipse(
              borderRadius: 30,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Weight',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  SizedBox(
                    width: 150,
                    child: GlassSegmentedControl(
                      segments: const ['kg', 'lbs'],
                      selectedIndex: _selectedSegment1,
                      onSegmentSelected: (index) {
                        setState(() { _selectedSegment1 = index; });
                        LocalStorage.saveWeightUnit(index);
                        DatabaseService().updateUnitSettings(weight: index); // ДОДАНО
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          GlassCard(
            height: 60,
            width: double.infinity,
            shape: const LiquidRoundedSuperellipse(
              borderRadius: 30,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Distance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: GlassSegmentedControl(
                      segments: const ['kilometers', 'miles'],
                      selectedIndex: _selectedSegment2,
                      onSegmentSelected: (index) {
                        setState(() { _selectedSegment2 = index; });
                        LocalStorage.saveDistanceUnit(index);
                        DatabaseService().updateUnitSettings(distance: index); // ДОДАНО
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          GlassCard(
            height: 60,
            width: double.infinity,
            shape: const LiquidRoundedSuperellipse(
              borderRadius: 30,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Body Measurements',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: GlassSegmentedControl(
                      segments: const ['cm', 'in'],
                      selectedIndex: _selectedSegment3,
                      onSegmentSelected: (index) {
                        setState(() { _selectedSegment3 = index; });
                        LocalStorage.saveMeasurementsUnit(index);
                        DatabaseService().updateUnitSettings(measurements: index); // ДОДАНО
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),

          const Text(
            'Notifications',
            style: TextStyle(color: Colors.white54, fontSize: 22),
          ),

          const Divider(color: Colors.grey, thickness: 0.5),

          GlassCard(
            height: 60,
            width: double.infinity,
            shape: const LiquidRoundedSuperellipse(
              borderRadius: 30,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Push notifications',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  GlassSwitch(
                    value: _isNotificationsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _isNotificationsEnabled = value;
                      });
                      LocalStorage.saveNotificationsState(value);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'Danger zone',
            style: TextStyle(color: Colors.white54, fontSize: 22),
          ),
          const Divider(color: Colors.grey, thickness: 0.5),

          GlassButton.custom(
            width: double.infinity,
            height: 60,
            shape: const LiquidRoundedSuperellipse(
              borderRadius: 30,
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();

              await LocalStorage.clear();

              UserSession.nickname = "Quixx User";

              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          GlassButton.custom(
            width: double.infinity,
            height: 60,
            shape: const LiquidRoundedSuperellipse(
              borderRadius: 30,
            ),
            settings: LiquidGlassSettings(
              glassColor: Colors.red.withValues(alpha: 0.7),
              ambientStrength: 0.6,
              thickness: 5,
            ),
            onTap: () async {
              try {
                // 1. Видаляємо акаунт користувача з Firebase Auth
                await FirebaseAuth.instance.currentUser?.delete();

                // 2. Очищаємо локальні дані
                await LocalStorage.clear();
                UserSession.nickname = "Quixx User";

                // 3. Перекидаємо на екран логіну
                if (context.mounted) {
                  context.go('/login');
                }
              } on FirebaseAuthException catch (e) {
                // Якщо з моменту останнього входу пройшло багато часу, Firebase вимагає re-authenticate.
                // Тут можна додати Snackbar з повідомленням про помилку.
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting account: ${e.message}. Please login again.')),
                  );
                }
              }
            },
            child: const Text(
              'Delete account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),

      top: const AppHeaderBar(
        title: 'Settings',
        secondButtonTitle: 'Done',
        secondButtonWidth: double.infinity,
      ),
    );
  }
}
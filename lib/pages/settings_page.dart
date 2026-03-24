import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../widgets/app_header_bar.dart';
import '../theme/showcase_glass_theme.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090012),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: 70,
                  left: 10,
                  right: 10,
                  bottom: 20,
                ),
                clipBehavior: Clip.none,
                child: AdaptiveLiquidGlassLayer(
                  settings: ShowcaseGlassTheme.profileButtonBig,
                  quality: ShowcaseGlassTheme.standardQuality,
                  child: Column(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),

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
                                  glassSettings:
                                      ShowcaseGlassTheme.profileButton,
                                  segments: const ['kg', 'lbs'],
                                  selectedIndex: _selectedSegment1,
                                  onSegmentSelected: (index) {
                                    setState(() {
                                      _selectedSegment1 = index;
                                    });
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
                                  glassSettings:
                                      ShowcaseGlassTheme.profileButton,
                                  segments: const ['kilometers', 'miles'],
                                  selectedIndex: _selectedSegment2,
                                  onSegmentSelected: (index) {
                                    setState(() {
                                      _selectedSegment2 = index;
                                    });
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
                                  glassSettings:
                                      ShowcaseGlassTheme.profileButton,
                                  segments: const ['cm', 'in'],
                                  selectedIndex: _selectedSegment3,
                                  onSegmentSelected: (index) {
                                    setState(() {
                                      _selectedSegment3 = index;
                                    });
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
                        onTap: () {},
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
                        onTap: () {},
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
                ),
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: AppHeaderBar(
                  title: 'Settings',
                  secondButtonTitle: 'Done',
                  secondButtonWidth: double.infinity,
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
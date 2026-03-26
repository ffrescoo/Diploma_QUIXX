import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:go_router/go_router.dart';
import '../navigation/appRouter.dart';
import '../widgets/appDefaultLayout.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedSegment = 0;

  @override
  Widget build(BuildContext context) {
    return AppDefaultLayout(
      body: Column(
        spacing: 15,
        children: [
          _buildUserHeader(),
          _buildEmptyStatsChart(),
          GlassSegmentedControl(
            segments: const ['Duration', 'Volume', 'Reps'],
            selectedIndex: _selectedSegment,
            onSegmentSelected: (index) {
              setState(() {
                _selectedSegment = index;
              });
            },
          ),
          _buildDashboardSection(),
          _buildWorkoutSection(),
        ],
      ),
      top: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GlassButton(
              icon: Icon(Icons.arrow_back),
              iconSize: 25,
              width: 45,
              height: 45,
              onTap: () => context.pop(),
            ),
            _buildTopActionButtons(),
          ],
        ),
    );
  }

  Widget _buildTopActionButtons() {
    return GlassTheme(
      data: GlassThemeData(
        light: GlassThemeVariant(
          glowColors: GlassGlowColors(primary: Colors.purple.withValues(alpha: 0)),
        ),
        dark: GlassThemeVariant(
          glowColors: GlassGlowColors(primary: Colors.purple.withValues(alpha: 0)),
        ),
      ),
      child: GlassButtonGroup(
        borderRadius: 30,
        borderColor: Colors.transparent,
        children: [
          GlassButton(
            icon: Icon(Icons.edit),
            style: GlassButtonStyle.transparent,
            width: 45,
            height: 45,
            iconSize: 25,
            onTap: () => context.push(
              AppRouter.editProfile,
              extra: 'assets/images/Avatar.svg',
            ),
          ),
          GlassButton(
            icon: Icon(Icons.share),
            style: GlassButtonStyle.transparent,
            width: 45,
            height: 45,
            iconSize: 25,
            onTap: () {},
          ),
          GlassButton(
            icon: Icon(Icons.settings),
            style: GlassButtonStyle.transparent,
            width: 45,
            height: 45,
            iconSize: 25,
            onTap: () => context.push(AppRouter.settingsPage),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/images/Avatar.svg',
              height: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "@NoNameUser",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem("0", "Workouts"),
                      _buildStatItem("0", "Followers"),
                      _buildStatItem("0", "Following"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStatsChart() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_graph_rounded, size: 60, color: Colors.white54),
            SizedBox(height: 10),
            Text(
              'No data yet',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardSection() {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          width: double.infinity,
            child: Column(
              spacing: 10,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Expanded(child: _buildMenuButton("Statistics", Icons.bar_chart_rounded)),
                    Expanded(child: _buildMenuButton("Exercises", Icons.fitness_center_rounded)),
                  ],
                ),
                Row(
                  spacing: 10,
                  children: [
                    Expanded(child: _buildMenuButton("Measures", Icons.straighten_rounded)),
                    Expanded(child: _buildMenuButton("Calendar", Icons.calendar_today_rounded)),
                  ],
                ),
              ],
            ),
        ),
      ],
    );
  }

  Widget _buildWorkoutSection() {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Workout',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 36, left: 36, right: 36),
              height: 150,
              decoration: BoxDecoration(
                  color: const Color(0xFF232323).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10)),
            ),
            Container(
              margin: const EdgeInsets.only(top: 24, left: 24, right: 24),
              height: 150,
              decoration: BoxDecoration(
                  color: const Color(0xFF232323).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10)),
            ),
            Container(
              margin: const EdgeInsets.only(top: 12, left: 12, right: 12),
              height: 150,
              decoration: BoxDecoration(
                  color: const Color(0xFF232323).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10)),
            ),
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF1B1B1B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fitness_center_rounded, size: 60, color: Colors.white54),
                    SizedBox(height: 10),
                    Text(
                      'No Workouts',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuButton(String label, IconData icon) {
    return GlassCard(
      height: 60,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedMeshGradient(
              colors: const [
                Color(0xFFCCB3D1),
                Color(0xFF4C4A6C),
                Color(0xFF22052D),
                Color(0xFF000000),
              ],
              options: AnimatedMeshGradientOptions(
                speed: 1,
                frequency: 3,
                amplitude: 15,
                grain: 0.1,
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _selectedTab,
              children: [
                const Center(child: Text('Home', style: TextStyle(color: Colors.white, fontSize: 24))),
                const Center(child: Text('Stats', style: TextStyle(color: Colors.white, fontSize: 24))),
                const Center(child: Text('Workout', style: TextStyle(color: Colors.white, fontSize: 24))),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {

    return GlassBottomBar(
      verticalPadding: 30,
      horizontalPadding: 30,
      indicatorColor: Colors.white24,
      extraButton: GlassBottomBarExtraButton(
        icon: Icons.person,

        label: 'Profile',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        },
      ),
      tabs: [
        GlassBottomBarTab(label: 'Home', icon: Icons.home_outlined, selectedIcon: Icons.home),
        GlassBottomBarTab(label: 'Stats', icon: Icons.insert_chart_outlined_rounded, selectedIcon: Icons.insert_chart_rounded),
        GlassBottomBarTab(label: 'Workout', icon: Icons.fitness_center_rounded, selectedIcon: Icons.fitness_center_rounded),
      ],
      selectedIndex: _selectedTab,
      onTabSelected: (index) => setState(() => _selectedTab = index),
    );
  }
}
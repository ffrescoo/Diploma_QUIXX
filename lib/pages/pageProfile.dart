import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:go_router/go_router.dart';
import '../navigation/appRouter.dart';
import '../widgets/appDefaultLayout.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/user_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';


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
    final dbService = DatabaseService();
    final currentUserId = dbService.uid;

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
                  Text(
                    UserSession.nickname,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Кількість тренувань (Workouts)
                      StreamBuilder<QuerySnapshot>(
                        stream: dbService.getCompletedWorkouts(),
                        builder: (context, snapshot) {
                          final workoutsCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                          return _buildStatItem("$workoutsCount", "Workouts");
                        },
                      ),

                      // Кількість підписників (Followers)
                      StreamBuilder<int>(
                        stream: dbService.getFollowersCountStream(currentUserId),
                        builder: (context, snapshot) {
                          final followersCount = snapshot.data ?? 0;
                          return _buildStatItem("$followersCount", "Followers");
                        },
                      ),

                      // Кількість підписок (Following)
                      StreamBuilder<int>(
                        stream: dbService.getFollowingCountStream(currentUserId),
                        builder: (context, snapshot) {
                          final followingCount = snapshot.data ?? 0;
                          return _buildStatItem("$followingCount", "Following");
                        },
                      ),
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
    final DatabaseService databaseService = DatabaseService();

    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Workout History',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: databaseService.getCompletedWorkouts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: Colors.white54),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              // Якщо історія порожня — показуємо ваш красивий Stack-дизайн
              return _buildEmptyWorkoutPlaceholder();
            }

            final docs = snapshot.data!.docs;

            return Column(
              spacing: 10,
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _buildCompletedWorkoutCard(data);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyWorkoutPlaceholder() {
    return Stack(
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
    );
  }

  Widget _buildCompletedWorkoutCard(Map<String, dynamic> data) {
    final String title = data['title'] ?? 'Workout';
    final int completedSets = data['completedSets'] ?? 0;
    final int totalSets = data['totalSets'] ?? 0;
    final int durationSeconds = data['durationInSeconds'] ?? 0;

    // Форматування тривалості (хв:сек)
    final minutes = (durationSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (durationSeconds % 60).toString().padLeft(2, '0');

    // Форматування дати
    String dateStr = '';
    if (data['completedAt'] != null) {
      final DateTime date = (data['completedAt'] as Timestamp).toDate();
      dateStr = "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent, size: 26),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sets: $completedSets/$totalSets • Time: $minutes:$seconds',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (dateStr.isNotEmpty)
            Text(
              dateStr,
              style: const TextStyle(
                color: Colors.white30,
                fontSize: 12,
              ),
            ),
        ],
      ),
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
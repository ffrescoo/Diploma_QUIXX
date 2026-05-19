import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:go_router/go_router.dart';
import '../navigation/appRouter.dart';
import '../widgets/appDefaultLayout.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/user_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../widgets/widget_chart.dart';
import 'package:fl_chart/fl_chart.dart' as fl_chart;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedSegment = 0;
  bool _isHistoryExpanded = false;
  late final Stream<QuerySnapshot> _workoutsStream;
  late final String _currentMonth;
  late final int _currentYear;
  late final Future<List<ChartData>> _statsFuture;
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _workoutsStream = _dbService.getCompletedWorkouts();
    final now = DateTime.now();
    _currentMonth = DateFormat('MMMM').format(now);
    _currentYear = now.year;
    _statsFuture = _dbService.getMonthlyStats(_dbService.uid, _currentMonth, _currentYear);
  }

  @override
  Widget build(BuildContext context) {
    return AppDefaultLayout(
      body: Column(
        spacing: 15,
        children: [
          _buildProfileCard(),
          _buildWorkoutSection(),
        ],
      ),
      top: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GlassButton(
            icon: const Icon(Icons.arrow_back),
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
            icon: const Icon(Icons.edit),
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
            icon: const Icon(Icons.share),
            style: GlassButtonStyle.transparent,
            width: 45,
            height: 45,
            iconSize: 25,
            onTap: () {},
          ),
          GlassButton(
            icon: const Icon(Icons.settings),
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
    final currentUserId = _dbService.uid;

    return SizedBox(
      width: double.infinity,
      height: 120,
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
                      StreamBuilder<QuerySnapshot>(
                        stream: _workoutsStream,
                        builder: (context, snapshot) {
                          final workoutsCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                          return _buildStatItem("$workoutsCount", "Workouts");
                        },
                      ),
                      StreamBuilder<int>(
                        stream: _dbService.getFollowersCountStream(currentUserId),
                        builder: (context, snapshot) {
                          final followersCount = snapshot.data ?? 0;
                          return _buildStatItem("$followersCount", "Followers");
                        },
                      ),
                      StreamBuilder<int>(
                        stream: _dbService.getFollowingCountStream(currentUserId),
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

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUserHeader(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              color: Colors.white10,
              thickness: 1,
              height: 1,
            ),
          ),
          _buildStatsChartSection(),
        ],
      ),
    );
  }

  Widget _buildChartShimmerLoading() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.3, end: 0.7),
      duration: const Duration(milliseconds: 1000),
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      onEnd: () {
        setState(() {});
      },
      child: SizedBox(
        height: 160,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 35),
              width: 120,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(4, (index) {
                  final heights = [100.0, 60.0, 110.0, 40.0];
                  return Container(
                    width: 30,
                    height: heights[index],
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsChartSection() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 15),
        child: Column(
          children: [
            FutureBuilder<List<ChartData>>(
              future: _statsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildChartShimmerLoading();
                }

                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyChartPlaceholder();
                }

                final chartList = snapshot.data!;

                final String targetUnitType = _selectedSegment == 0
                    ? 'time'
                    : (_selectedSegment == 1 ? 'volume' : 'reps');

                ChartData? activeChartData;
                try {
                  activeChartData = chartList.firstWhere((chart) => chart.unitType == targetUnitType);
                } catch (_) {
                  activeChartData = null;
                }

                if (activeChartData == null) {
                  return _buildEmptyChartPlaceholder();
                }

                final values = activeChartData.values;
                final maxVal = values.isEmpty ? 0.0 : values.reduce(math.max);

                double interval = 1.0;
                if (maxVal != 0) {
                  final rawInterval = maxVal / 3;
                  final exponent = (math.log(rawInterval) / math.ln10).floorToDouble();
                  final magnitude = math.pow(10, exponent).toDouble();
                  final residual = rawInterval / magnitude;
                  final niceResidual = residual <= 1.0 ? 1.0 : residual <= 2.0 ? 2.0 : residual <= 2.5 ? 2.5 : residual <= 3.0 ? 3.0 : residual <= 4.0 ? 4.0 : residual <= 5.0 ? 5.0 : 10.0;
                  interval = niceResidual * magnitude;
                }
                final maxY = interval * 3.3;

                final suffixes = ['th', 'st', 'nd', 'rd'];
                final labels = List.generate(values.length, (i) {
                  final num = i + 1;
                  String suff = 'th';
                  if (!(num >= 11 && num <= 13)) {
                    final mod = num % 10;
                    if (mod <= 3 && mod > 0) suff = suffixes[mod];
                  }
                  return '$num${suff}w';
                });

                return SizedBox(
                  height: 160,
                  child: VolumeBarChartContent(
                    chartData: activeChartData,
                    maxY: maxY,
                    interval: interval,
                    labels: labels,
                  ),
                );
              },
            ),
            const SizedBox(height: 15),

            // Наш селектор
            GlassSegmentedControl(
              segments: const ['Duration', 'Volume', 'Reps'],
              selectedIndex: _selectedSegment,
              onSegmentSelected: (index) {
                setState(() {
                  _selectedSegment = index;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChartPlaceholder() {
    return const SizedBox(
      height: 160,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_graph_rounded, size: 50, color: Colors.white54),
          SizedBox(height: 8),
          Text(
            'No data yet',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _workoutsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white54));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyWorkoutPlaceholder();
        }

        final docs = snapshot.data!.docs;

        const double cardHeight = 80.0;
        const double collapsedStep = 12.0;
        const double expandedStep = cardHeight + 12.0;

        final double totalHeight = _isHistoryExpanded
            ? (docs.length * expandedStep) - 12.0
            : cardHeight + (math.min(docs.length, 3) - 1) * collapsedStep;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Workout History',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IntrinsicWidth(
                  child: GlassButton.custom(
                    width: double.infinity,
                    height: 26,
                    shape: const LiquidRoundedSuperellipse(borderRadius: 13),
                    onTap: () {
                      setState(() {
                        _isHistoryExpanded = !_isHistoryExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: Text(
                        _isHistoryExpanded ? 'Collapse' : 'Show all',
                        style: const TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastLinearToSlowEaseIn,
              height: totalHeight,
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: docs.asMap().entries.map((entry) {
                  int index = entry.key;
                  final data = entry.value.data() as Map<String, dynamic>;

                  final bool isWithinTopThree = index < 3;
                  final double collapsedTop = isWithinTopThree ? (index * collapsedStep) : (2 * collapsedStep);

                  final double targetTop = _isHistoryExpanded
                      ? (index * expandedStep)
                      : collapsedTop;

                  final double targetScale = _isHistoryExpanded
                      ? 1.0
                      : (isWithinTopThree ? 1.0 - (index * 0.04) : 0.92);

                  final double targetOpacity = _isHistoryExpanded
                      ? 1.0
                      : (isWithinTopThree ? 1.0 - (index * 0.15) : 0.0);

                  final bool isVisible = _isHistoryExpanded || isWithinTopThree;

                  return AnimatedPositioned(
                    key: ValueKey(entry.value.id),
                    duration: Duration(milliseconds: 400 + (index * 30)),
                    curve: Curves.fastOutSlowIn,
                    top: targetTop,
                    left: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      duration: Duration(milliseconds: _isHistoryExpanded ? 300 : 150),
                      opacity: isVisible ? targetOpacity : 0.0,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOutBack,
                        scale: targetScale,
                        alignment: Alignment.bottomCenter,
                        child: IgnorePointer(
                          ignoring: !isVisible,
                          child: _buildCompletedWorkoutCard(data),
                        ),
                      ),
                    ),
                  );
                }).toList().reversed.toList(),
              ),
            ),
          ],
        );
      },
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

    final minutes = (durationSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (durationSeconds % 60).toString().padLeft(2, '0');

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
        crossAxisAlignment: CrossAxisAlignment.center,
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
              mainAxisSize: MainAxisSize.min,
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

class VolumeBarChartContent extends StatelessWidget {
  final ChartData chartData;
  final double maxY;
  final double interval;
  final List<String> labels;

  const VolumeBarChartContent({
    super.key,
    required this.chartData,
    required this.maxY,
    required this.interval,
    required this.labels,
  });

  String _formatYLabel(double value) {
    if (value == 0) return '0';

    switch (chartData.unitType) {
      case 'volume':
        return '${(value / 1000).toStringAsFixed(0)}k kg';
      case 'time':
        return value % 1 == 0
            ? '${value.toInt()}h'
            : '${value.toStringAsFixed(1)}h';
      default:
        return value % 1 == 0
            ? value.toInt().toString()
            : value.toStringAsFixed(1);
    }
  }

  bool _isMainGrid(double value) {
    final remainder = (value % interval);
    return remainder.abs() < 0.01 && value <= interval * 3.01;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 35),
            child: Text(
              chartData.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final count = chartData.values.length;
                const spacing = 18.0;
                final availableWidth = constraints.maxWidth - 150;
                final rodWidth = math.max<double>(
                  2.0,
                  (availableWidth - spacing * (count + 1)) / count,
                );

                return fl_chart.BarChart(
                  fl_chart.BarChartData(
                    maxY: maxY,
                    alignment: fl_chart.BarChartAlignment.spaceEvenly,
                    titlesData: fl_chart.FlTitlesData(
                      bottomTitles: fl_chart.AxisTitles(
                        sideTitles: fl_chart.SideTitles(
                          showTitles: true,
                          reservedSize: 20,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= labels.length) {
                              return const SizedBox();
                            }
                            return fl_chart.SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                labels[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 8,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: fl_chart.AxisTitles(
                        sideTitles: fl_chart.SideTitles(
                          showTitles: true,
                          interval: interval,
                          reservedSize: 35,
                          getTitlesWidget: (value, meta) {
                            if (!_isMainGrid(value)) {
                              return const SizedBox();
                            }
                            return fl_chart.SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                _formatYLabel(value),
                                maxLines: 1,
                                softWrap: false,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 8,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: const fl_chart.AxisTitles(sideTitles: fl_chart.SideTitles(showTitles: false)),
                      topTitles: const fl_chart.AxisTitles(sideTitles: fl_chart.SideTitles(showTitles: false)),
                    ),
                    gridData: fl_chart.FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: interval,
                      checkToShowHorizontalLine: _isMainGrid,
                      getDrawingHorizontalLine: (_) => fl_chart.FlLine(
                        color: Colors.white.withValues(alpha: 0.15),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: fl_chart.FlBorderData(
                      show: true,
                      border: Border(
                        left: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1),
                        bottom: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1),
                      ),
                    ),
                    barGroups: List.generate(chartData.values.length, (i) {
                      return fl_chart.BarChartGroupData(
                        x: i,
                        barRods: [
                          fl_chart.BarChartRodData(
                            toY: chartData.values[i],
                            color: const Color(0xFFD1CFD7),
                            width: rodWidth,
                            borderRadius: BorderRadius.zero,
                          ),
                        ],
                      );
                    }),
                  ),
                );
              },
            ),
          ),
        ],
      );
  }
}
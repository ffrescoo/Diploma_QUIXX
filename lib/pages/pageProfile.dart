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
  late final Stream<QuerySnapshot> _workoutsStream;
  late final Stream<QuerySnapshot> _myPostsStream;
  late final String _currentMonth;
  late final int _currentYear;
  late final Future<List<ChartData>> _statsFuture;
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _workoutsStream = _dbService.getCompletedWorkouts();
    _myPostsStream = _dbService.getUserPostsStream(_dbService.uid);
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
          _buildPostsSection(),
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

  Widget _buildPostsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _myPostsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white54),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Помилка завантаження постів', style: TextStyle(color: Colors.white54)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'У вас ще немає постів',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        // Використовуємо QueryDocumentSnapshot замість Map<String, dynamic>
        return AnimatedStackSection<QueryDocumentSnapshot>(
          title: 'My Posts',
          items: docs,
          cardHeight: 224.0,
          itemIdProvider: (doc) => doc.id,
          itemBuilder: (context, doc) => _buildPostCardItem(doc),
        );
      },
    );
  }

  Widget _buildPostCardItem(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Зчитуємо реальні дані з Firebase (назви полів взяті з твого tabHome.dart)
    final String content = data['description'] ?? '';
    final String postUsername = data['username'] ?? UserSession.nickname;
    final int likes = data['likes'] ?? 0;
    final String postImage = data['postImage'] ?? '';
    final bool hasImage = postImage.isNotEmpty;

    // Форматуємо дату (якщо поле createdAt існує у твоїх документах Firebase)
    String dateStr = '';
    if (data.containsKey('createdAt') && data['createdAt'] != null) {
      final DateTime date = (data['createdAt'] as Timestamp).toDate();
      dateStr = "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}";
    }

    return Container(
      width: double.infinity,
      height: 224,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 150,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(15),
              // Якщо є зображення, можна його показати, або залишити іконку
              image: hasImage
                  ? DecorationImage(
                image: NetworkImage(postImage),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: hasImage
                ? null
                : const Icon(
              Icons.article_rounded,
              color: Colors.white38,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          postUsername,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            color: Colors.white30,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      content,
                      maxLines: 7,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      '$likes',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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

    return StreamBuilder<DocumentSnapshot>(
      // Слухаємо зміни в документі поточного користувача
      stream: FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots(),
      builder: (context, snapshot) {
        // Дефолтні значення
        String avatarUrl = 'assets/images/Avatar.svg';
        String nickname = UserSession.nickname;

        // Якщо дані завантажено з БД, беремо їх
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            avatarUrl = data['avatarUrl'] ?? avatarUrl;
            nickname = data['username'] ?? data['nickname'] ?? nickname;
          }
        }

        // Перевіряємо, чи це посилання з інтернету (Cloudinary), чи локальний файл
        Widget avatarWidget;
        if (avatarUrl.startsWith('http')) {
          avatarWidget = Image.network(avatarUrl, fit: BoxFit.cover);
        } else {
          avatarWidget = SvgPicture.asset(avatarUrl, fit: BoxFit.cover);
        }

        return SizedBox(
          width: double.infinity,
          height: 120,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Віджет аватарки
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white10,
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: avatarWidget,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Віджет нікнейму
                      Text(
                        nickname,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
      },
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

        return AnimatedStackSection<QueryDocumentSnapshot>(
          title: 'Workout History',
          items: docs,
          cardHeight: 80.0,
          itemIdProvider: (doc) => doc.id,
          itemBuilder: (context, doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _buildCompletedWorkoutCard(data);
          },
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
        return value % 1 == 0 ? '${value.toInt()}h' : '${value.toStringAsFixed(1)}h';
      default:
        return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);
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

/// Універсальний віджет для створення анімованого каскадного списку (стека)
class AnimatedStackSection<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final double cardHeight;
  final double collapsedStep;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String Function(T item) itemIdProvider;

  const AnimatedStackSection({
    super.key,
    required this.title,
    required this.items,
    required this.cardHeight,
    this.collapsedStep = 12.0,
    required this.itemBuilder,
    required this.itemIdProvider,
  });

  @override
  State<AnimatedStackSection<T>> createState() => _AnimatedStackSectionState<T>();
}

class _AnimatedStackSectionState<T> extends State<AnimatedStackSection<T>> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final double expandedStep = widget.cardHeight + widget.collapsedStep;

    final double totalHeight = _isExpanded
        ? (widget.items.length * expandedStep) - widget.collapsedStep
        : widget.cardHeight + (math.min(widget.items.length, 3) - 1) * widget.collapsedStep;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
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
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Text(
                    _isExpanded ? 'Collapse' : 'Show all',
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
            children: widget.items.asMap().entries.map((entry) {
              int index = entry.key;
              final item = entry.value;

              final bool isWithinTopThree = index < 3;
              final double collapsedTop = isWithinTopThree
                  ? (index * widget.collapsedStep)
                  : (2 * widget.collapsedStep);

              final double targetTop = _isExpanded
                  ? (index * expandedStep)
                  : collapsedTop;

              final double targetScale = _isExpanded
                  ? 1.0
                  : (isWithinTopThree ? 1.0 - (index * 0.04) : 0.92);

              final double targetOpacity = _isExpanded
                  ? 1.0
                  : (isWithinTopThree ? 1.0 - (index * 0.15) : 0.0);

              final bool isVisible = _isExpanded || isWithinTopThree;

              return AnimatedPositioned(
                key: ValueKey(widget.itemIdProvider(item)),
                duration: Duration(milliseconds: 400 + (index * 30)),
                curve: Curves.fastOutSlowIn,
                top: targetTop,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: _isExpanded ? 300 : 150),
                  opacity: isVisible ? targetOpacity : 0.0,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutBack,
                    scale: targetScale,
                    alignment: Alignment.bottomCenter,
                    child: IgnorePointer(
                      ignoring: !isVisible,
                      child: widget.itemBuilder(context, item),
                    ),
                  ),
                ),
              );
            }).toList().reversed.toList(),
          ),
        ),
      ],
    );
  }
}
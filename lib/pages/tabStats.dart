import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/glass_theme.dart';
import '../widgets/widget_month_picker.dart';
import '../widgets/widget_chart.dart';
import '../widgets/appDefaultLayout.dart';
import '../services/database_service.dart';
import '../services/user_session.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  String _selectedMonth = 'May';
  final int _currentYear = 2026;
  final DatabaseService _dbService = DatabaseService();

  Future<List<ChartData>> _fetchStats() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return await _dbService.getMonthlyStats(userId, _selectedMonth, _currentYear);
  }

  String _calculateTotalTime(List<ChartData> data) {
    try {
      final timeData = data.firstWhere((element) => element.unitType == 'time');
      final totalHours = timeData.values.reduce((a, b) => a + b);
      if (totalHours >= 1) {
        return '${totalHours.toStringAsFixed(1)} hours';
      }
      return '${(totalHours * 60).toInt()} mins';
    } catch (_) {
      return '0 mins';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDefaultLayout(
      // 1. Огортаємо у StreamBuilder для отримання налаштувань (kg/lbs) у реальному часі
      body: StreamBuilder<UserModel?>(
        stream: _dbService.userProfileStream,
        builder: (context, userSnapshot) {
          final userModel = userSnapshot.data;
          // Перевіряємо, чи вибрав користувач фунти (індекс 1)
          final bool isLbs = userModel?.weightUnit == 1;

          return FutureBuilder<List<ChartData>>(
            future: _fetchStats(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No data found', style: const TextStyle(color: Colors.white)));
              }

              // 2. Конвертуємо дані, якщо увімкнені фунти
              var chartList = snapshot.data!.map((data) {
                if (data.unitType == 'volume') {
                  List<double> finalValues = data.values;
                  String suffix = 'kg';

                  if (isLbs) {
                    // Конвертуємо кг у фунти (1 kg ≈ 2.20462 lbs)
                    finalValues = data.values.map((v) => v * 2.20462).toList();
                    suffix = 'lbs';
                  }

                  return ChartData(
                    title: data.title,
                    unitType: data.unitType,
                    ySuffix: suffix, // Передаємо мітку
                    values: finalValues,
                  );
                }
                return data;
              }).toList();

              // Динамічний підрахунок макс. ваги (приклад: 120 кг або 264 фунти)
              // У майбутньому сюди можна передати реальну макс вагу з БД
              final String maxWeightValue = isLbs ? '264 lbs' : '120 kg';

              return Column(
                spacing: 12,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.80,
                    child: Row(
                      spacing: 12,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Column(
                            spacing: 12,
                            children: chartList.map((data) => GlassChart(chartData: data)).toList(),
                          ),
                        ),
                        MonthPicker(
                          selectedMonth: _selectedMonth,
                          onMonthChanged: (month) {
                            setState(() {
                              _selectedMonth = month;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  _buildStatPanel(
                    title: 'Total Month Time',
                    value: _calculateTotalTime(chartList),
                    iconPath: 'assets/images/hourglass.png',
                  ),

                  _buildStatPanel(
                    title: 'Max Weight',
                    value: maxWeightValue, // Використовуємо динамічне значення
                    iconPath: 'assets/images/dumbell1.png',
                  ),

                  const SizedBox(height: 80),
                ],
              );
            },
          );
        },
      ),
      top: const SizedBox(height: 0),
      topSpacing: 15,
    );
  }

  Widget _buildStatPanel({
    required String title,
    required String value,
    required String iconPath,
  }) {
    // ... ваш існуючий код _buildStatPanel залишається без змін ...
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    const padding = EdgeInsets.symmetric(horizontal: 10, vertical: 20);

    return RepaintBoundary(
      child: GlassContainer(
        settings: ShowcaseGlassTheme.profilePanelDark,
        width: double.infinity,
        shape: const LiquidRoundedSuperellipse(borderRadius: 20),
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              ImageIcon(AssetImage(iconPath), size: 40, color: Colors.white),
              const SizedBox(width: 10),
              Text(title, style: textStyle),
              const Spacer(),
              Text(value, style: textStyle),
            ],
          ),
        ),
      ),
    );
  }
}
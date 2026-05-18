import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/glass_theme.dart';
import '../widgets/widget_month_picker.dart';
import '../widgets/widget_chart.dart';
import '../widgets/appDefaultLayout.dart';
import '../services/database_service.dart';
import '../services/user_session.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  // Стан поточного вибраного місяця та року
  String _selectedMonth = 'March';
  final int _currentYear = 2026;

  final DatabaseService _dbService = DatabaseService();

  // Новий метод отримання даних з БД замість читання локального файлу JSON
  Future<List<ChartData>> _fetchStats() async {
    // Отримуємо ID поточного користувача з сесії
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Робимо запит до нашого сервісу
    return await _dbService.getMonthlyStats(userId, _selectedMonth, _currentYear);
  }

  // Допоміжний метод для розрахунку загального часу тренувань за місяць
  String _calculateTotalTime(List<ChartData> data) {
    try {
      // Шукаємо графік із типом 'time'
      final timeData = data.firstWhere((element) => element.unitType == 'time');
      // Сумуємо значення за всі 4 тижні
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
      body: FutureBuilder<List<ChartData>>(
        future: _fetchStats(), // Викликається знову при кожному виклику setState через зміну місяця
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found', style: const TextStyle(color: Colors.white)));
          }

          final chartList = snapshot.data!;

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
                    // Інтегруємо MonthPicker з передачею стану та колбеку
                    MonthPicker(
                      selectedMonth: _selectedMonth,
                      onMonthChanged: (month) {
                        setState(() {
                          _selectedMonth = month; // Змінюємо місяць, що викликає оновлення FutureBuilder
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Відображаємо динамічно розрахований час тренувань
              _buildStatPanel(
                title: 'Total Month Time',
                value: _calculateTotalTime(chartList),
                iconPath: 'assets/images/hourglass.png',
              ),

              _buildStatPanel(
                title: 'Max Weight',
                value: '120 kg',
                iconPath: 'assets/images/dumbell1.png',
              ),

              const SizedBox(height: 80),
            ],
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
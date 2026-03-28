import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/glass_theme.dart';
import '../widgets/widget_month_picker.dart';
import '../widgets/widget_chart.dart';
import '../widgets/appDefaultLayout.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  Future<List<ChartData>> _loadChartData() async {
    final String response = await rootBundle.loadString('assets/data/chart_data.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => ChartData.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppDefaultLayout(
      body: FutureBuilder<List<ChartData>>(
        future: _loadChartData(),
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
                    const MonthPicker(),
                  ],
                ),
              ),

              _buildStatPanel(
                title: 'Time',
                value: '56 mins',
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
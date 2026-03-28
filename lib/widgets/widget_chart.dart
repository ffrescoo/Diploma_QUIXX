import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/glass_theme.dart';

class ChartData {
  final String title;
  final String unitType;
  final List<double> values;

  ChartData({required this.title, required this.unitType, required this.values});

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      title: json['title'],
      unitType: json['unitType'],
      values: List<double>.from(json['values']),
    );
  }
}

class GlassChart extends StatelessWidget {
  final ChartData chartData;

  const GlassChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    final interval = _getNiceInterval(chartData.values);
    final maxY = interval * 3.01;

    final labels = List.generate(
        chartData.values.length,
            (i) => '${i + 1}${_getOrdinalSuffix(i + 1)} week');

    return Expanded(
      child: GlassContainer(
        settings: ShowcaseGlassTheme.profilePanelDark,
        width: double.infinity,
        shape: const LiquidRoundedSuperellipse(borderRadius: 20),
        child: _VolumeBarChartContent(
            chartData: chartData, maxY: maxY, interval: interval, labels: labels),
      ),
    );
  }

  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) return 'th';
    switch (number % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  double _getNiceInterval(List<double> values) {
    if (values.isEmpty) return 1.0;
    double maxVal = values.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) return 10.0;

    double rawInterval = maxVal / 3;
    double exponent = (log(rawInterval) / ln10).floorToDouble();
    double magnitude = pow(10, exponent).toDouble();
    double residual = rawInterval / magnitude;

    double niceResidual;

    if (residual <= 1.0) {
      niceResidual = 1.0;
    } else if (residual <= 2.0) {
      niceResidual = 2.0;
    } else if (residual <= 2.5) {
      niceResidual = 2.5;
    } else if (residual <= 3.0) {
      niceResidual = 3.0;
    } else if (residual <= 4.0) {
      niceResidual = 4.0;
    } else if (residual <= 5.0) {
      niceResidual = 5.0;
    } else {
      niceResidual = 10.0;
    }

    return niceResidual * magnitude;
  }
}

class _VolumeBarChartContent extends StatelessWidget {
  final ChartData chartData;
  final double maxY;
  final double interval;
  final List<String> labels;

  const _VolumeBarChartContent(
      {required this.chartData, required this.maxY, required this.interval, required this.labels});

  String _formatYLabel(double value) {
    if (value == 0) return '0';
    if (chartData.unitType == 'volume') return '${(value / 1000).toStringAsFixed(0)}k kg';
    if (chartData.unitType == 'time') return '${value.toStringAsFixed(1)}h';
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chartData.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.spaceEvenly,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= labels.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            labels[value.toInt()],
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
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: interval,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value > interval * 3.1) return const SizedBox();

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
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
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  // Перевірка, щоб малювати тільки 4 лінії
                  checkToShowHorizontalLine: (value) => value <= interval * 3.1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withValues(alpha: 0.15),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1),
                    bottom: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1),
                  ),
                ),
                barGroups: List.generate(chartData.values.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: chartData.values[i],
                        color: const Color(0xFFD1CFD7),
                        width: 25,
                        borderRadius: BorderRadius.zero,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
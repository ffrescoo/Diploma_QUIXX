import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/glass_theme.dart';

class ChartData {
  final String title;
  final String unitType;
  final List<double> values;

  const ChartData({
    required this.title,
    required this.unitType,
    required this.values,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      title: json['title'],
      unitType: json['unitType'],
      values: (json['values'] as List).cast<double>(),
    );
  }
}

class GlassChart extends StatelessWidget {
  final ChartData chartData;

  const GlassChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    final values = chartData.values;

    final interval = _getNiceInterval(values);
    final maxY = interval * 3.3;

    final labels = List.generate(
      values.length,
          (i) => '${i + 1}${_getOrdinalSuffix(i + 1)}w',
    );

    return Expanded(
      child: GlassContainer(
        settings: ShowcaseGlassTheme.profilePanelDark,
        width: double.infinity,
        shape: const LiquidRoundedSuperellipse(borderRadius: 20),
        child: _VolumeBarChartContent(
          chartData: chartData,
          maxY: maxY,
          interval: interval,
          labels: labels,
        ),
      ),
    );
  }

  static const _suffixes = ['th', 'st', 'nd', 'rd'];

  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) return 'th';
    final mod = number % 10;
    return (mod <= 3 && mod > 0) ? _suffixes[mod] : 'th';
  }

  double _getNiceInterval(List<double> values) {
    if (values.isEmpty) return 1.0;

    final maxVal = values.reduce(max);
    if (maxVal == 0) return 10.0;

    final rawInterval = maxVal / 3;
    final exponent = (log(rawInterval) / ln10).floorToDouble();
    final magnitude = pow(10, exponent).toDouble();
    final residual = rawInterval / magnitude;

    final niceResidual = switch (residual) {
      <= 1.0 => 1.0,
      <= 2.0 => 2.0,
      <= 2.5 => 2.5,
      <= 3.0 => 3.0,
      <= 4.0 => 4.0,
      <= 5.0 => 5.0,
      _ => 10.0,
    };

    return niceResidual * magnitude;
  }
}

class _VolumeBarChartContent extends StatelessWidget {
  final ChartData chartData;
  final double maxY;
  final double interval;
  final List<String> labels;

  const _VolumeBarChartContent({
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
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 35),
            child: Text(
              chartData.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
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

                final availableWidth =
                    constraints.maxWidth - 12;

                final rodWidth = max<double>(
                  2.0,
                  (availableWidth - spacing * (count + 1)) / count,
                );

                return BarChart(
                  BarChartData(
                    maxY: maxY,
                    alignment: BarChartAlignment.spaceEvenly,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 20,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= labels.length) {
                              return const SizedBox();
                            }

                            return SideTitleWidget(
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
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: interval,
                          reservedSize: 35,
                          getTitlesWidget: (value, meta) {
                            if (!_isMainGrid(value)) {
                              return const SizedBox();
                            }

                            return SideTitleWidget(
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
                      rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: interval,
                      checkToShowHorizontalLine: _isMainGrid,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: Colors.white.withValues(alpha: 0.15),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        left: BorderSide(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 1,
                        ),
                        bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                    ),
                    barGroups: List.generate(chartData.values.length, (i) {
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
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
      ),
    );
  }
}
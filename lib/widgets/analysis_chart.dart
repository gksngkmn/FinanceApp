import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisChart extends StatelessWidget {
  final List<FlSpot> spots;
  final double minY, maxY;

  const AnalysisChart({
    super.key,
    required this.spots,
    required this.minY,
    required this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchSpotThreshold: 10,
          handleBuiltInTouches: true,
          mouseCursorResolver: (FlTouchEvent event, LineTouchResponse? response) {
            if (response == null || response.lineBarSpots == null || response.lineBarSpots!.isEmpty) {
              return SystemMouseCursors.basic;
            }
            return SystemMouseCursors.precise;
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF334155),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                return LineTooltipItem(
                  '${touchedSpot.y.toStringAsFixed(0)} TL',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) == 0 ? 1 : (maxY - minY) / 5,
          getDrawingHorizontalLine: (value) => const FlLine(color: Color(0xFFE2E8F0), strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            left: BorderSide(color: Color(0xFF64748B), width: 1),
            bottom: BorderSide(color: Color(0xFF64748B), width: 1),
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                bool showLabel = value % 5 == 0 && value != 0;
                return Column(
                  children: [
                    Container(width: 1, height: 4, color: const Color(0xFF64748B)),
                    if (showLabel) const SizedBox(height: 2),
                    if (showLabel)
                      Text('+${value.toInt()}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                  ],
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48, // Sayıların çakışmaması için nefes payı
              interval: (maxY - minY) == 0 ? 1 : (maxY - minY) / 5, // Dinamik aralık hesaplaması
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Text(''); // 0 değerini gizle
                
                double absValue = value.abs();
                String formattedText = '';

                // Profesyonel finansal formatlama (1M, 500k gibi)
                if (absValue >= 1000000) {
                  formattedText = '${(value / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
                } else if (absValue >= 1000) {
                  formattedText = '${(value / 1000).toStringAsFixed(0)}k';
                } else {
                  formattedText = value.toStringAsFixed(0);
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    formattedText, 
                    style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
        ),
        minX: 0,
        maxX: 30,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false, // Kesin çizgi grafiği
            color: const Color(0xFF1565C0),
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: const Color(0xFF1565C0).withOpacity(0.1)),
          ),
        ],
      ),
    );
  }
}
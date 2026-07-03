// lib/screens/analysis_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class AnalysisScreen extends StatefulWidget {
  final List<CompanyTransaction> transactions;

  const AnalysisScreen({super.key, required this.transactions});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  double _currentBalance = 0;
  double _upcomingIncome = 0;
  double _upcomingExpense = 0;
  List<FlSpot> _chartSpots = [];
  double _minY = 0;
  double _maxY = 0;
  List<CompanyTransaction> _upcomingTransactions = [];

  @override
  void initState() {
    super.initState();
    _calculateForecast();
  }

  @override
  void didUpdateWidget(covariant AnalysisScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _calculateForecast();
  }

  void _calculateForecast() {
    DateTime today = DateTime.now();
    DateTime todayStart = DateTime(today.year, today.month, today.day);
    DateTime thirtyDaysLater = todayStart.add(const Duration(days: 30));

    _currentBalance = 0;
    _upcomingIncome = 0;
    _upcomingExpense = 0;
    _upcomingTransactions = [];

    for (var tx in widget.transactions) {
      DateTime txDate = tx.dueDate ?? tx.date;
      DateTime normalizedTxDate = DateTime(txDate.year, txDate.month, txDate.day);

      if (normalizedTxDate.isBefore(todayStart) || normalizedTxDate.isAtSameMomentAs(todayStart)) {
        _currentBalance += (tx.type == TransactionType.gelir ? tx.amount : -tx.amount);
      } 
      else if (normalizedTxDate.isBefore(thirtyDaysLater) || normalizedTxDate.isAtSameMomentAs(thirtyDaysLater)) {
        _upcomingTransactions.add(tx);
        if (tx.type == TransactionType.gelir) {
          _upcomingIncome += tx.amount;
        } else {
          _upcomingExpense += tx.amount;
        }
      }
    }

    _upcomingTransactions.sort((a, b) => (a.dueDate ?? a.date).compareTo(b.dueDate ?? b.date));

    _chartSpots = [];
    double runningBalance = _currentBalance;
    _chartSpots.add(FlSpot(0, runningBalance));

    _minY = runningBalance;
    _maxY = runningBalance;

    for (int i = 1; i <= 30; i++) {
      DateTime targetDay = todayStart.add(Duration(days: i));
      double dailyNet = 0;

      for (var tx in _upcomingTransactions) {
        DateTime txDate = tx.dueDate ?? tx.date;
        if (txDate.year == targetDay.year && txDate.month == targetDay.month && txDate.day == targetDay.day) {
          dailyNet += (tx.type == TransactionType.gelir ? tx.amount : -tx.amount);
        }
      }

      runningBalance += dailyNet;
      _chartSpots.add(FlSpot(i.toDouble(), runningBalance));

      if (runningBalance < _minY) _minY = runningBalance;
      if (runningBalance > _maxY) _maxY = runningBalance;
    }

    double yRange = _maxY - _minY;
    if (yRange == 0) yRange = 1000;
    _minY -= (yRange * 0.1);
    _maxY += (yRange * 0.1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aylık Nakit Akışı Öngörüsü (Forecasting)',
              style: TextStyle(fontSize: 22, color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Sistemdeki vadeler baz alınarak gelecek 30 günün tahmini kasa durumu hesaplanmıştır.',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(child: _buildMetricCard('Şu Anki Net Kasa', _currentBalance, const Color(0xFF1E293B), Icons.account_balance_wallet)),
                const SizedBox(width: 16),
                Expanded(child: _buildMetricCard('+ Beklenen Tahsilat (30 Gün)', _upcomingIncome, const Color(0xFF2E7D32), Icons.arrow_downward)),
                const SizedBox(width: 16),
                Expanded(child: _buildMetricCard('- Beklenen Çıkış (30 Gün)', _upcomingExpense, const Color(0xFFC62828), Icons.arrow_upward)),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Card(
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(side: const BorderSide(color: Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 24, left: 16, top: 24, bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('30 Günlük Kasa Trendi', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                            const SizedBox(height: 24),
                            Expanded(
                              child: _chartSpots.isEmpty ? const Center(child: CircularProgressIndicator()) : LineChart(
                                LineChartData(
                                  
                                  // ---> İŞTE BURASI: EKLENEN YENİ TOOLTIP AYARI <---
                                  lineTouchData: LineTouchData(
                                    touchTooltipData: LineTouchTooltipData(
                                      getTooltipColor: (touchedSpot) => const Color(0xFF334155), // Koyu arka plan
                                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                        return touchedSpots.map((LineBarSpot touchedSpot) {
                                          return LineTooltipItem(
                                            '${touchedSpot.y.toStringAsFixed(2)} TL',
                                            const TextStyle(
                                              color: Colors.white, // BEYAZ YAZI
                                              fontWeight: FontWeight.bold, 
                                              fontSize: 12
                                            ),
                                          );
                                        }).toList();
                                      },
                                    ),
                                  ),
                                  // --------------------------------------------------

                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    getDrawingHorizontalLine: (value) => const FlLine(color: Color(0xFFF1F5F9), strokeWidth: 1),
                                  ),
                                  titlesData: FlTitlesData(
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 30,
                                        interval: 5,
                                        getTitlesWidget: (value, meta) {
                                          if (value == 0) return _bottomTitleText('Bugün');
                                          return _bottomTitleText('+${value.toInt()} Gün');
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 60,
                                        getTitlesWidget: (value, meta) {
                                          String text = value >= 1000 ? '${(value / 1000).toStringAsFixed(0)}k' : value.toStringAsFixed(0);
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: Text(text, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11), textAlign: TextAlign.right),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  minX: 0,
                                  maxX: 30,
                                  minY: _minY,
                                  maxY: _maxY,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: _chartSpots,
                                      isCurved: true,
                                      color: const Color(0xFF1565C0),
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: const FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: const Color(0xFF1565C0).withOpacity(0.1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  Expanded(
                    flex: 1,
                    child: Card(
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(side: const BorderSide(color: Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Yaklaşan Vade Listesi', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                            const Divider(color: Color(0xFFE2E8F0)),
                            Expanded(
                              child: _upcomingTransactions.isEmpty
                                  ? const Center(child: Text('Önümüzdeki 30 gün için planlanmış bir işlem yok.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B))))
                                  : ListView.builder(
                                      itemCount: _upcomingTransactions.length,
                                      itemBuilder: (context, index) {
                                        final tx = _upcomingTransactions[index];
                                        final isIncome = tx.type == TransactionType.gelir;
                                        return ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: CircleAvatar(
                                            backgroundColor: isIncome ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                                            child: Icon(
                                              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                              color: isIncome ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                              size: 16,
                                            ),
                                          ),
                                          title: Text(tx.description, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          subtitle: Text(DateFormat('dd/MM/yyyy').format(tx.dueDate ?? tx.date), style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                          trailing: Text(
                                            '${isIncome ? "+" : "-"}${tx.amount.toStringAsFixed(0)} TL',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isIncome ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomTitleText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Text(text, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
    );
  }

  Widget _buildMetricCard(String title, double value, Color valueColor, IconData icon) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(side: const BorderSide(color: Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: valueColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: valueColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('${value.toStringAsFixed(2)} TL', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: valueColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
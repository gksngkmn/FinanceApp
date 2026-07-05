// lib/screens/analysis_screen.dart

import 'package:financialanalysisapp/widgets/analysis_chart.dart';
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
  // Filtre için tarih aralığı değişkeni eklendi
  DateTimeRange? _selectedDateRange;
  
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
    // 1. Tarih aralığını belirle (Filtre seçilmediyse varsayılan 30 gün)
    DateTime startDate = _selectedDateRange?.start ?? DateTime.now();
    DateTime endDate = _selectedDateRange?.end ?? DateTime.now().add(const Duration(days: 30));

    // 2. Hesaplama değişkenlerini sıfırla
    double currentRunningBalance = 0;
    double totalIncome = 0;
    double totalExpense = 0;
    List<CompanyTransaction> filteredTransactions = [];
    List<FlSpot> spots = [];

    // 3. Seçilen aralıktaki işlemleri filtrele
    filteredTransactions = widget.transactions.where((tx) {
      DateTime txDate = tx.dueDate ?? tx.date;
      return txDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             txDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    // 4. Gelir ve Gider toplamlarını hesapla
    for (var tx in filteredTransactions) {
      if (tx.isIncome) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }

    // 5. Grafik için bakiye değişimini gün gün hesapla
    int daysDifference = endDate.difference(startDate).inDays;
    
    for (int i = 0; i <= daysDifference; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));
      double dailyChange = 0;

      for (var tx in filteredTransactions) {
        DateTime txDate = tx.dueDate ?? tx.date;
        if (txDate.year == currentDate.year && 
            txDate.month == currentDate.month && 
            txDate.day == currentDate.day) {
          dailyChange += tx.isIncome ? tx.amount : -tx.amount;
        }
      }
      
      currentRunningBalance += dailyChange;
      spots.add(FlSpot(i.toDouble(), currentRunningBalance));
    }

    // 6. UI değişkenlerini güncelle
    setState(() {
      _upcomingIncome = totalIncome;
      _upcomingExpense = totalExpense;
      _upcomingTransactions = filteredTransactions;
      _chartSpots = spots;

      if (spots.isNotEmpty) {
        double minVal = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
        double maxVal = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
        _minY = minVal - 1000;
        _maxY = maxVal + 1000;
      }
    });
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
            // BAŞLIK VE FİLTRE BUTONU
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aylık Nakit Akışı Öngörüsü (Forecasting)',
                      style: TextStyle(fontSize: 22, color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Seçilen tarihler baz alınarak tahmin hesaplanmıştır.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                // FİLTRE BUTONU BURADA
OutlinedButton.icon(
                  onPressed: () async {
                    // showDateRangePicker yerine standart showDialog kullanıyoruz
                    DateTimeRange? picked = await showDialog<DateTimeRange>(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          // Dialog boyutunu Container ile sabitliyoruz
                          child: Container(
                            width: 400, // Genişliği sabitledik (tüm ekranı kaplamayacak)
                            height: 520, // Yüksekliği sabitledik
                            padding: const EdgeInsets.all(8.0),
                            // Flutter'ın çekirdek DateRangePicker widget'ı
                            child: DateRangePickerDialog(
                              firstDate: DateTime(2023),
                              lastDate: DateTime(2030),
                              initialDateRange: _selectedDateRange ?? DateTimeRange(
                                start: DateTime.now(), 
                                end: DateTime.now().add(const Duration(days: 30))
                              ),
                            ),
                          ),
                        );
                      },
                    );

                    // Eğer kullanıcı bir tarih seçip "Kaydet/Tamam" dediyse:
                    if (picked != null) {
                      setState(() {
                        _selectedDateRange = picked;
                        _calculateForecast(); // Verileri ve grafiği yenile
                      });
                    }
                  },
                  icon: const Icon(Icons.filter_alt_outlined, size: 20, color: Color(0xFF1E293B)),
                  label: Text(
                    _selectedDateRange == null
                        ? 'Tarih Filtrele'
                        : '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(child: _buildMetricCard('Şu Anki Net Kasa', _currentBalance, const Color(0xFF1E293B), Icons.account_balance_wallet)),
                const SizedBox(width: 16),
                Expanded(child: _buildMetricCard('Beklenen Tahsilat', _upcomingIncome, const Color(0xFF2E7D32), Icons.arrow_downward)),
                const SizedBox(width: 16),
                Expanded(child: _buildMetricCard('Beklenen Çıkış', _upcomingExpense, const Color(0xFFC62828), Icons.arrow_upward)),
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
                            const Text('Seçilen Tarih Aralığı Trendi', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                            const SizedBox(height: 24),
                            Expanded(
                              child: _chartSpots.isEmpty ? const Center(child: Text("Gösterilecek veri bulunamadı."))
                              : AnalysisChart(spots: _chartSpots, minY: _minY, maxY: _maxY),
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
                            const Text('Vade Listesi', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                            const Divider(color: Color(0xFFE2E8F0)),
                            Expanded(
                              child: _upcomingTransactions.isEmpty
                                  ? const Center(child: Text('Seçilen tarihte işlem yok.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B))))
                                  : ListView.builder(
                                      itemCount: _upcomingTransactions.length,
                                      itemBuilder: (context, index) {
                                        final tx = _upcomingTransactions[index];
                                        final isIncome = tx.isIncome;
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
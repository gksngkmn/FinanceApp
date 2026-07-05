// lib/screens/reports_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../services/excel_service.dart';
import '../widgets/report_list_title.dart';

class ReportsScreen extends StatefulWidget {
  final List<CompanyTransaction> transactions;

  const ReportsScreen({super.key, required this.transactions});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // State (Durum) Değişkenleri
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;
  TransactionType? _selectedType;
  PaymentMethod? _selectedMethod;
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();

  // İş Yükü (Business Logic) - Filtreleme
  List<CompanyTransaction> get _filteredTransactions {
    return widget.transactions.where((tx) {
      final searchLower = _searchQuery.toLowerCase();
      final matchesSearch = tx.description.toLowerCase().contains(searchLower) ||
          (tx.bankName?.toLowerCase().contains(searchLower) ?? false) ||
          (tx.checkNumber?.toLowerCase().contains(searchLower) ?? false);

      final matchesDate = _selectedDateRange == null ||
          (tx.date.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
           tx.date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1))));

      final matchesType = _selectedType == null || tx.type == _selectedType;
      final matchesMethod = _selectedMethod == null || tx.method == _selectedMethod;

      double? minAmount = double.tryParse(_minAmountController.text);
      double? maxAmount = double.tryParse(_maxAmountController.text);
      final matchesMinAmount = minAmount == null || tx.amount >= minAmount;
      final matchesMaxAmount = maxAmount == null || tx.amount <= maxAmount;

      return matchesSearch && matchesDate && matchesType && matchesMethod && matchesMinAmount && matchesMaxAmount;
    }).toList();
  }

  InputDecoration _compactDecoration(String hint, {Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
      prefixIcon: prefixIcon,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
    );
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredTransactions;
    const double filterHeight = 38.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Raporlar', style: TextStyle(fontSize: 18)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              // OOP Prensibi: İşlemi dışarıdaki servise devrettik
              onPressed: () => ExcelService.exportTransactions(context, filteredList),
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Excel\'e Aktar', style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // FİLTRE PANELİ
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: filterHeight,
                        child: TextField(
                          style: const TextStyle(fontSize: 13),
                          decoration: _compactDecoration('Açıklama, Banka veya Çek No...', prefixIcon: const Icon(Icons.search, size: 18)),
                          onChanged: (value) => setState(() => _searchQuery = value),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: filterHeight,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.date_range, size: 16),
                          label: Text(_selectedDateRange == null ? 'Tarih Aralığı' : '${DateFormat('dd/MM').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM').format(_selectedDateRange!.end)}', style: const TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          onPressed: () async {
                            final picked = await showDialog<DateTimeRange>(
                              context: context,
                              builder: (context) => Dialog(
                                child: Container(
                                  width: 400, height: 500, padding: const EdgeInsets.all(8),
                                  child: DateRangePickerDialog(firstDate: DateTime(2020), lastDate: DateTime(2030), initialDateRange: _selectedDateRange),
                                ),
                              ),
                            );
                            if (picked != null) setState(() => _selectedDateRange = picked);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      height: filterHeight, width: filterHeight,
                      child: IconButton(
                        icon: const Icon(Icons.clear_all, color: Colors.red, size: 20),
                        tooltip: 'Temizle',
                        onPressed: () => setState(() {
                          _searchQuery = ''; _selectedDateRange = null; _selectedType = null;
                          _selectedMethod = null; _minAmountController.clear(); _maxAmountController.clear();
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: filterHeight,
                        child: DropdownButtonFormField<TransactionType>(
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                          iconSize: 18,
                          decoration: _compactDecoration(''),
                          hint: const Text('Tip', style: TextStyle(fontSize: 12)),
                          value: _selectedType,
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Tümü')),
                            DropdownMenuItem(value: TransactionType.gelir, child: Text('Gelir')),
                            DropdownMenuItem(value: TransactionType.gider, child: Text('Gider')),
                          ],
                          onChanged: (val) => setState(() => _selectedType = val),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: filterHeight,
                        child: DropdownButtonFormField<PaymentMethod>(
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                          iconSize: 18,
                          decoration: _compactDecoration(''),
                          hint: const Text('Yöntem', style: TextStyle(fontSize: 12)),
                          value: _selectedMethod,
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Tümü')),
                            DropdownMenuItem(value: PaymentMethod.nakit, child: Text('Nakit')),
                            DropdownMenuItem(value: PaymentMethod.cek, child: Text('Çek')),
                          ],
                          onChanged: (val) => setState(() => _selectedMethod = val),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: filterHeight,
                        child: TextField(
                          controller: _minAmountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 13),
                          decoration: _compactDecoration('Min TL'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: filterHeight,
                        child: TextField(
                          controller: _maxAmountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 13),
                          decoration: _compactDecoration('Max TL'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            color: const Color(0xFFE2E8F0),
            child: Text('${filteredList.length} kayıt bulundu', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          ),

          // LİSTE GÖRÜNÜMÜ
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                // OOP Prensibi: Kapsüllediğimiz (Encapsulated) Widget'ı çağırıyoruz.
                return ReportListTile(transaction: filteredList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
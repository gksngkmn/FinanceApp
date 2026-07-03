// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_table.dart';
import '../widgets/transaction_form_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<CompanyTransaction> _allTransactions = [];
  String _searchQuery = '';
  DateTime? _selectedDate;

  List<CompanyTransaction> get _filteredTransactions {
    return _allTransactions.where((tx) {
      final matchesName = tx.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDate = _selectedDate == null ||
          (tx.dueDate != null &&
           tx.dueDate!.year == _selectedDate!.year &&
           tx.dueDate!.month == _selectedDate!.month &&
           tx.dueDate!.day == _selectedDate!.day);
      return matchesName && matchesDate;
    }).toList();
  }

  double get _totalIncome => _filteredTransactions.where((tx) => tx.type == TransactionType.gelir).fold(0.0, (s, tx) => s + tx.amount);
  double get _totalExpense => _filteredTransactions.where((tx) => tx.type == TransactionType.gider).fold(0.0, (s, tx) => s + tx.amount);
  double get _totalProfit => _totalIncome - _totalExpense;

  void _showMethodSelection(TransactionType type) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(type == TransactionType.gelir ? 'Gelir Türü Seçin' : 'Gider Türü Seçin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.money, color: Colors.green),
                title: const Text('Nakit İşlem'),
                onTap: () {
                  Navigator.pop(context);
                  _openTransactionForm(type, PaymentMethod.nakit);
                },
              ),
              ListTile(
                leading: const Icon(Icons.analytics, color: Colors.blue),
                title: Text(type == TransactionType.gelir ? 'Çek Giriş Bordrosu' : 'Çek Çıkış Bordrosu'),
                onTap: () {
                  Navigator.pop(context);
                  _openTransactionForm(type, PaymentMethod.cek);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Yeni veya Düzenleme için formu açan metod
  void _openTransactionForm(TransactionType type, PaymentMethod method, {CompanyTransaction? transactionToEdit}) {
    showDialog(
      context: context,
      builder: (context) {
        return TransactionFormDialog(
          type: type,
          method: method,
          transactionToEdit: transactionToEdit,
          onSave: (savedTransaction) {
            setState(() {
              if (transactionToEdit != null) {
                // Mevcut kaydı bul ve güncelle
                int index = _allTransactions.indexWhere((t) => t.id == savedTransaction.id);
                if (index != -1) {
                  _allTransactions[index] = savedTransaction;
                }
              } else {
                // Yeni kayıt ekle
                _allTransactions.add(savedTransaction);
              }
            });
          },
        );
      },
    );
  }

  // Silme Onay Penceresi ve İşlemi
  void _deleteTransaction(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('İşlemi Sil'),
          content: const Text('Bu kaydı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                setState(() {
                  _allTransactions.removeWhere((tx) => tx.id == id);
                });
                Navigator.pop(context);
              },
              child: const Text('Sil', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Göksun Gökmen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                    const Text('Gökmen Yazılım Ltd. Şti.', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('GELİR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600),
                      onPressed: () => _showMethodSelection(TransactionType.gelir),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.remove, color: Colors.white),
                      label: const Text('GİDER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
                      onPressed: () => _showMethodSelection(TransactionType.gider),
                    ),
                  ],
                )
              ],
            ),
            const Divider(height: 30, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: SummaryCard(title: 'Toplam Gelir', value: _totalIncome, color: Colors.green)),
                const SizedBox(width: 8),
                Expanded(child: SummaryCard(title: 'Toplam Gider', value: _totalExpense, color: Colors.red)),
                const SizedBox(width: 8),
                Expanded(child: SummaryCard(title: 'Net Kâr / Zarar', value: _totalProfit, color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'İsme / Firmaya Göre Filtrele', border: OutlineInputBorder(), prefixIcon: Icon(Icons.search), contentPadding: EdgeInsets.symmetric(vertical: 0)),
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.date_range, size: 18),
                    label: Text(_selectedDate == null ? 'Vade Filtresi' : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
                    onPressed: () async {
                      final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                  ),
                ),
                if (_selectedDate != null)
                  IconButton(icon: const Icon(Icons.clear, color: Colors.red), onPressed: () => setState(() => _selectedDate = null))
              ],
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: TransactionTable(
                transactions: _filteredTransactions,
                onEdit: (tx) => _openTransactionForm(tx.type, tx.method, transactionToEdit: tx),
                onDelete: (id) => _deleteTransaction(id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
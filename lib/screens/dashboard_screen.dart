// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_table.dart';
import '../widgets/transaction_form_dialog.dart';

class DashboardScreen extends StatefulWidget {
  final List<CompanyTransaction> transactions;
  final Function(CompanyTransaction) onAdd;
  final Function(CompanyTransaction) onUpdate;
  final Function(String) onDelete;

  const DashboardScreen({
    super.key,
    required this.transactions,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _searchQuery = '';
  DateTime? _selectedDate;

  List<CompanyTransaction> get _filteredTransactions {
    return widget.transactions.where((tx) {
      final matchesName = tx.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDate = _selectedDate == null ||
          (tx.dueDate != null &&
           tx.dueDate!.year == _selectedDate!.year &&
           tx.dueDate!.month == _selectedDate!.month &&
           tx.dueDate!.day == _selectedDate!.day);
      return matchesName && matchesDate;
    }).toList();
  }

  double get _totalIncome => _filteredTransactions.where((tx) => tx.type == TransactionType.gelir).fold(0.0, (sum, tx) => sum + tx.amount);
  double get _totalExpense => _filteredTransactions.where((tx) => tx.type == TransactionType.gider).fold(0.0, (sum, tx) => sum + tx.amount);
  double get _totalProfit => _totalIncome - _totalExpense;

  void _showMethodSelection(TransactionType type) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(type == TransactionType.gelir ? 'Gelir Türü Seçin' : 'Gider Türü Seçin', style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.money, color: Color(0xFF2E7D32)), // Soft Yeşil
                title: const Text('Nakit İşlem', style: TextStyle(color: Color(0xFF334155))),
                onTap: () { Navigator.pop(context); _openTransactionForm(type, PaymentMethod.nakit); },
              ),
              ListTile(
                leading: const Icon(Icons.analytics, color: Color(0xFF1565C0)), // Soft Mavi
                title: Text(type == TransactionType.gelir ? 'Çek Giriş Bordrosu' : 'Çek Çıkış Bordrosu', style: const TextStyle(color: Color(0xFF334155))),
                onTap: () { Navigator.pop(context); _openTransactionForm(type, PaymentMethod.cek); },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openTransactionForm(TransactionType type, PaymentMethod method, {CompanyTransaction? transactionToEdit}) {
    showDialog(
      context: context,
      builder: (context) {
        return TransactionFormDialog(
          type: type,
          method: method,
          transactionToEdit: transactionToEdit,
          onSave: (savedTransaction) {
            if (transactionToEdit != null) {
              widget.onUpdate(savedTransaction);
            } else {
              widget.onAdd(savedTransaction);
            }
            setState(() {});
          },
        );
      },
    );
  }

  void _deleteTransaction(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('İşlemi Sil', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
          content: const Text('Bu kaydı silmek istediğinize emin misiniz?', style: TextStyle(color: Color(0xFF334155))),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828)), // Soft Koyu Kırmızı
              onPressed: () { widget.onDelete(id); Navigator.pop(context); setState(() {}); },
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Göksun Gökmen', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    SizedBox(height: 4),
                    Text('Gökmen Yazılım Ltd. Şti.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('GELİR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)), // Soft Yeşil
                      onPressed: () => _showMethodSelection(TransactionType.gelir),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.remove, color: Colors.white),
                      label: const Text('GİDER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828)), // Soft Kırmızı
                      onPressed: () => _showMethodSelection(TransactionType.gider),
                    ),
                  ],
                )
              ],
            ),
            const Divider(height: 40, thickness: 1, color: Color(0xFFE2E8F0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: SummaryCard(title: 'Toplam Gelir', value: _totalIncome, color: const Color(0xFF2E7D32))),
                const SizedBox(width: 12),
                Expanded(child: SummaryCard(title: 'Toplam Gider', value: _totalExpense, color: const Color(0xFFC62828))),
                const SizedBox(width: 12),
                Expanded(child: SummaryCard(title: 'Net Kâr / Zarar', value: _totalProfit, color: const Color(0xFF1565C0))),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'İsme / Firmaya Göre Filtrele',
                        labelStyle: TextStyle(color: Color(0xFF64748B)),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFCBD5E1))),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF475569))),
                        prefixIcon: Icon(Icons.search, color: Color(0xFF64748B)),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.date_range, size: 18),
                    label: Text(_selectedDate == null ? 'Vade Filtresi' : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF475569),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                  ),
                ),
                if (_selectedDate != null)
                  IconButton(icon: const Icon(Icons.clear, color: Color(0xFFC62828)), onPressed: () => setState(() => _selectedDate = null))
              ],
            ),
            const SizedBox(height: 20),
            Expanded(child: TransactionTable(
              transactions: _filteredTransactions,
              onEdit: (tx) => _openTransactionForm(tx.type, tx.method, transactionToEdit: tx),
              onDelete: (id) => _deleteTransaction(id),
            )),
          ],
        ),
      ),
    );
  }
}
// lib/widgets/report_list_tile.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class ReportListTile extends StatelessWidget {
  final CompanyTransaction transaction;

  const ReportListTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFE2E8F0)), 
        borderRadius: BorderRadius.circular(6)
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: transaction.isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
          child: Icon(transaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward, 
              color: transaction.isIncome ? Colors.green : Colors.red, size: 18),
        ),
        title: Text(transaction.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(
          '${DateFormat('dd/MM/yyyy').format(transaction.date)} • ${transaction.method == PaymentMethod.nakit ? 'Nakit' : 'Çek'}', 
          style: const TextStyle(fontSize: 11)
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${transaction.isIncome ? "+" : "-"}${transaction.amount.toStringAsFixed(2)} TL', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: transaction.isIncome ? Colors.green : Colors.red)
            ),
            if (transaction.dueDate != null) 
              Text('Vade: ${DateFormat('dd/MM').format(transaction.dueDate!)}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
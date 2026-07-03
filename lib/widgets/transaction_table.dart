// lib/widgets/transaction_table.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class TransactionTable extends StatelessWidget {
  final List<CompanyTransaction> transactions;
  final Function(CompanyTransaction) onEdit;
  final Function(String) onDelete;

  const TransactionTable({
    super.key,
    required this.transactions,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Text(
          'Kayıtlı işlem bulunamadı veya filtreyle eşleşmedi.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), color: Colors.white),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  dataRowMinHeight: 32,
                  dataRowMaxHeight: 38,
                  headingRowHeight: 40,
                  columnSpacing: 16,
                  horizontalMargin: 12,
                  dataTextStyle: const TextStyle(fontSize: 12, color: Colors.black87),
                  headingTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                  border: TableBorder.symmetric(inside: BorderSide(color: Colors.grey.shade300, width: 0.5)),
                  headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                  columns: const [
                    DataColumn(label: Text('Kayıt Tarihi')),
                    DataColumn(label: Text('Vade/İşlem Tarihi')),
                    DataColumn(label: Text('Firma / Şahıs Adı')),
                    DataColumn(label: Text('Tür')),
                    DataColumn(label: Text('Yöntem')),
                    DataColumn(label: Text('Bordro Detayları')),
                    DataColumn(label: Text('Miktar (TL)')),
                    DataColumn(label: Text('İşlemler')), // YENİ SÜTUN
                  ],
                  rows: transactions.map((tx) {
                    String details = "-";
                    if (tx.method == PaymentMethod.cek) {
                      details = "${tx.bankName ?? ''} | No: ${tx.checkNumber ?? ''} | ${tx.checkStatus ?? ''}";
                    }
                    return DataRow(cells: [
                      DataCell(Text(DateFormat('dd/MM/yyyy').format(tx.date))),
                      DataCell(Text(
                        DateFormat('dd/MM/yyyy').format(tx.dueDate ?? tx.date),
                        style: TextStyle(color: tx.method == PaymentMethod.cek ? Colors.red.shade700 : Colors.blue.shade700, fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text(tx.description)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: tx.type == TransactionType.gelir ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tx.type == TransactionType.gelir ? 'GELİR' : 'GİDER',
                            style: TextStyle(color: tx.type == TransactionType.gelir ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ),
                      ),
                      DataCell(Text(tx.method == PaymentMethod.cek ? 'Çek' : 'Nakit')),
                      DataCell(Text(details, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))),
                      DataCell(Text('${tx.amount.toStringAsFixed(2)} TL', style: const TextStyle(fontWeight: FontWeight.bold))),
                      
                      // YENİ EKLENEN İKONLAR
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 18),
                              tooltip: 'Düzenle',
                              onPressed: () => onEdit(tx),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                              tooltip: 'Sil',
                              onPressed: () => onDelete(tx.id),
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
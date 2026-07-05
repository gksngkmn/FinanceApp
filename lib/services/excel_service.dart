// lib/services/excel_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction_model.dart';

class ExcelService {
  // Static metod kullanarak instance oluşturmadan direkt çağırabilmeyi sağlıyoruz
  static Future<void> exportTransactions(BuildContext context, List<CompanyTransaction> transactions) async {
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dışa aktarılacak veri bulunamadı!')));
      return;
    }

    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Kayıtlar'];
      excel.setDefaultSheet('Kayıtlar');

      // Başlıklar
      sheetObject.appendRow([
        TextCellValue('İşlem ID'), TextCellValue('Tarih'), TextCellValue('Açıklama'),
        TextCellValue('Tip'), TextCellValue('Yöntem'), TextCellValue('Tutar (TL)'),
        TextCellValue('Vade'), TextCellValue('Banka Adı'), TextCellValue('Çek No'),
      ]);

      // Veriler
      for (var tx in transactions) {
        sheetObject.appendRow([
          TextCellValue(tx.id),
          TextCellValue(DateFormat('dd/MM/yyyy').format(tx.date)),
          TextCellValue(tx.description),
          TextCellValue(tx.isIncome ? 'Gelir' : 'Gider'),
          TextCellValue(tx.method == PaymentMethod.nakit ? 'Nakit' : 'Çek'),
          DoubleCellValue(tx.amount),
          TextCellValue(tx.dueDate != null ? DateFormat('dd/MM/yyyy').format(tx.dueDate!) : '-'),
          TextCellValue(tx.bankName ?? '-'),
          TextCellValue(tx.checkNumber ?? '-'),
        ]);
      }

      // Kaydet ve Paylaş
      var fileBytes = excel.save();
      final directory = await getTemporaryDirectory();
      final fileName = 'Finans_Raporu_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsBytes(fileBytes!);
      await Share.shareXFiles([XFile(file.path)], text: 'Finansal Kayıt Raporu');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }
}
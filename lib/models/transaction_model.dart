// lib/models/transaction_model.dart

enum TransactionType { gelir, gider }
enum PaymentMethod { nakit, cek }

class CompanyTransaction {
  final String id;
  final String description; // Company / Person Name
  final double amount;
  final TransactionType type;
  final PaymentMethod method;
  final DateTime date; // Entry Date

  bool get isIncome => type == TransactionType.gelir;

  // Check Specific Details
  final DateTime? dueDate; // Vade (Due Date)
  final String? drawerName; // Keşideci (Original Issuer)
  final String? bankName; // Banka
  final String? branchName; // Şube
  final String? accountNumber; // Hesap No
  final String? checkNumber; // Çek No
  final String? checkStatus; // Ciro / Tahsilat Durumu

  CompanyTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.method,
    required this.date,
    this.dueDate,
    this.drawerName,
    this.bankName,
    this.branchName,
    this.accountNumber,
    this.checkNumber,
    this.checkStatus,
  });
}
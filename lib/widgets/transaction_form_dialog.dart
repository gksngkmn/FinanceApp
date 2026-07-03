// lib/widgets/transaction_form_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class TransactionFormDialog extends StatefulWidget {
  final TransactionType type;
  final PaymentMethod method;
  final Function(CompanyTransaction) onSave;
  final CompanyTransaction? transactionToEdit; // Düzenleme modu için eklendi

  const TransactionFormDialog({
    super.key,
    required this.type,
    required this.method,
    required this.onSave,
    this.transactionToEdit,
  });

  @override
  State<TransactionFormDialog> createState() => _TransactionFormDialogState();
}

class _TransactionFormDialogState extends State<TransactionFormDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _drawerController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _accountNoController = TextEditingController();
  final TextEditingController _checkNoController = TextEditingController();

  String _selectedCheckStatus = 'Portföyde';
  late DateTime _formDate;
  late DateTime _dueDate;

  final List<String> _checkStatusOptions = ['Portföyde', 'Banka Tahsilat', 'Ciro Edildi', 'Kendi Çekimiz', 'Teminat'];

  @override
  void initState() {
    super.initState();
    
    // Eğer düzenleme modundaysak, mevcut verileri kutulara doldur
    if (widget.transactionToEdit != null) {
      final tx = widget.transactionToEdit!;
      _nameController.text = tx.description;
      _amountController.text = tx.amount.toString();
      _formDate = tx.date;
      _dueDate = tx.dueDate ?? tx.date;
      
      if (tx.method == PaymentMethod.cek) {
        _drawerController.text = tx.drawerName ?? '';
        _bankController.text = tx.bankName ?? '';
        _branchController.text = tx.branchName ?? '';
        _accountNoController.text = tx.accountNumber ?? '';
        _checkNoController.text = tx.checkNumber ?? '';
        _selectedCheckStatus = tx.checkStatus ?? 'Portföyde';
      }
    } else {
      _formDate = DateTime.now();
      _dueDate = widget.method == PaymentMethod.cek ? DateTime.now().add(const Duration(days: 30)) : DateTime.now();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _drawerController.dispose();
    _bankController.dispose();
    _branchController.dispose();
    _accountNoController.dispose();
    _checkNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.transactionToEdit != null;

    return AlertDialog(
      title: Text(
        '${isEditing ? "Düzenle: " : ""}${widget.type == TransactionType.gelir ? "Gelir" : "Gider"} | ${widget.method == PaymentMethod.nakit ? "Nakit" : "Çek"}',
        style: TextStyle(color: widget.type == TransactionType.gelir ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(flex: 2, child: TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Firma / Şahıs Adı', border: OutlineInputBorder()))),
                  const SizedBox(width: 12),
                  Expanded(flex: 1, child: TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Miktar (TL)', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey.shade50, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Kayıt Tarihi: ${DateFormat('dd/MM/yyyy').format(_formDate)}', style: TextStyle(color: Colors.grey.shade700)),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(context: context, initialDate: _formDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
                            if (picked != null) setState(() => _formDate = picked);
                          },
                          child: const Text('Değiştir'),
                        ),
                      ],
                    ),
                    const Divider(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Vade / İşlem Tarihi: ${DateFormat('dd/MM/yyyy').format(_dueDate)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(context: context, initialDate: _dueDate, firstDate: DateTime(2020), lastDate: DateTime(2035));
                            if (picked != null) setState(() => _dueDate = picked);
                          },
                          child: const Text('Değiştir'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (widget.method == PaymentMethod.cek) ...[
                const SizedBox(height: 12),
                const Divider(height: 30, thickness: 1),
                const Align(alignment: Alignment.centerLeft, child: Text('Çek Detayları (Bordro)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey))),
                const SizedBox(height: 12),
                TextField(controller: _drawerController, decoration: const InputDecoration(labelText: 'Keşideci (Asıl Çek Sahibi)', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _bankController, decoration: const InputDecoration(labelText: 'Banka Adı', border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: _branchController, decoration: const InputDecoration(labelText: 'Şube Adı', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _accountNoController, decoration: const InputDecoration(labelText: 'Hesap No', border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: _checkNoController, decoration: const InputDecoration(labelText: 'Çek No', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCheckStatus,
                        decoration: const InputDecoration(labelText: 'İşlem Durumu', border: OutlineInputBorder()),
                        items: _checkStatusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) { if (val != null) setState(() => _selectedCheckStatus = val); },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
          onPressed: () {
            if (_nameController.text.isEmpty || _amountController.text.isEmpty) return;
            
            final newTransaction = CompanyTransaction(
              // Eğer düzenleme yapıyorsak eski ID'yi koru, yeniyse yeni ID üret
              id: widget.transactionToEdit?.id ?? DateTime.now().toString(),
              description: _nameController.text,
              amount: double.tryParse(_amountController.text) ?? 0.0,
              type: widget.type,
              method: widget.method,
              date: _formDate,
              dueDate: _dueDate,
              drawerName: widget.method == PaymentMethod.cek ? _drawerController.text : null,
              bankName: widget.method == PaymentMethod.cek ? _bankController.text : null,
              branchName: widget.method == PaymentMethod.cek ? _branchController.text : null,
              accountNumber: widget.method == PaymentMethod.cek ? _accountNoController.text : null,
              checkNumber: widget.method == PaymentMethod.cek ? _checkNoController.text : null,
              checkStatus: widget.method == PaymentMethod.cek ? _selectedCheckStatus : null,
            );
            
            widget.onSave(newTransaction);
            Navigator.pop(context);
          },
          child: Text(isEditing ? 'Güncelle' : 'Kaydet'),
        ),
      ],
    );
  }
}
// lib/screens/main_layout.dart
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import 'dashboard_screen.dart';
import 'analysis_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final List<CompanyTransaction> _allTransactions = [];

  void _addTransaction(CompanyTransaction tx) {
    setState(() { _allTransactions.add(tx); });
  }

  void _updateTransaction(CompanyTransaction updatedTx) {
    setState(() {
      int index = _allTransactions.indexWhere((t) => t.id == updatedTx.id);
      if (index != -1) _allTransactions[index] = updatedTx;
    });
  }

  void _deleteTransaction(String id) {
    setState(() { _allTransactions.removeWhere((tx) => tx.id == id); });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardScreen(
        transactions: _allTransactions,
        onAdd: _addTransaction,
        onUpdate: _updateTransaction,
        onDelete: _deleteTransaction,
      ),
      AnalysisScreen(transactions: _allTransactions),
    ];

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: const Color(0xFFE2E8F0), // Soft Açık Mavi/Gri Mutfak (Slate 200)
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() { _selectedIndex = index; });
            },
            selectedIconTheme: const IconThemeData(color: Color(0xFF1E293B)), // Koyu Slate
            selectedLabelTextStyle: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
            unselectedIconTheme: const IconThemeData(color: Color(0xFF64748B)),
            unselectedLabelTextStyle: const TextStyle(color: Color(0xFF64748B)),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Kayıt / Pano')),
              NavigationRailDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: Text('Finansal Analiz')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1, color: Color(0xFFCBD5E1)),
          Expanded(child: pages[_selectedIndex]),
        ],
      ),
    );
  }
}
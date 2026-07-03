// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/main_layout.dart';

void main() {
  runApp(const AccountingApp());
}

class AccountingApp extends StatelessWidget {
  const AccountingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finansal Analiz Sistemi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Kırık Beyaz / Açık Gri (Slate 50)
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF475569), // Dingin Mat Lacivert / Gri (Slate 600)
          surface: Colors.white,      // Kart ve Tablo Arka Planları Temiz Beyaz
        ),
        appBarTheme: const Color(0xFFF8FAFC) == Colors.white 
            ? const AppBarTheme(backgroundColor: Colors.white, elevation: 0)
            : const AppBarTheme(backgroundColor: Color(0xFFF8FAFC), elevation: 0),
        useMaterial3: true,
      ),
      home: const MainLayout(),
    );
  }
}
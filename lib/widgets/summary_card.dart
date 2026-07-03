// lib/widgets/summary_card.dart

import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final double value;
  final Color color;

  // Constructor (Yapıcı Metot) - Dışarıdan bu 3 bilgiyi almasını zorunlu kılıyoruz.
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              '${value.toStringAsFixed(2)} TL',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
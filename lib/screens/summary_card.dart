import 'package:flutter/material.dart';
import '../models/model_report.dart';

class SummaryCard extends StatelessWidget {
  final List<ReportModel> reports;

  const SummaryCard({super.key, required this.reports});

  @override
  Widget build(BuildContext context) {
    final total = reports.length;
    final selesai =
        reports.where((r) => r.status == "selesai").length;

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.bar_chart, size: 40, color: Colors.green),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Laporan: $total",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Selesai: $selesai",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

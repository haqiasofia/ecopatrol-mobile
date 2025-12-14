import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/report_providers.dart';
import 'add_report_screen.dart';
import 'setting_screen.dart';
import '../screens/summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(reportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard EcoPatrol"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddReportScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // 🔹 RINGKASAN LAPORAN
          SummaryCard(reports: reports),

          // 🔹 LIST LAPORAN
          Expanded(
            child: reports.isEmpty
                ? const Center(
              child: Text("Belum ada laporan"),
            )
                : ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                final isDone = report.status == "selesai";

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(report.title),
                    subtitle: Text(report.description),
                    trailing: Chip(
                      label: Text(
                        isDone ? "Selesai" : "Pending",
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor:
                      isDone ? Colors.green : Colors.red,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

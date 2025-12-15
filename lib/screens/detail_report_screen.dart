import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/model_report.dart';
import '../providers/report_providers.dart';
import 'edit_report_screen.dart';

class DetailReportScreen extends ConsumerWidget {
  final int reportId;

  const DetailReportScreen({Key? key, required this.reportId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(reportProvider); // SESUAIKAN NAMA PROVIDER
    final report = reports.firstWhere(
          (r) => r.id == reportId,
      orElse: () => throw Exception('Report not found'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Laporan'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditReportScreen(reportId: reportId),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. FOTO FULL SIZE
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(File(report.photoPath)),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: 20),

            // 2. STATUS
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: report.status == 'completed'
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                report.status == 'completed' ? 'SELESAI' : 'PENDING',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: report.status == 'completed' ? Colors.green : Colors.red,
                ),
              ),
            ),

            SizedBox(height: 16),

            // 3. DETAIL LAPORAN
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      report.description,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),

                    SizedBox(height: 16),

                    // LOKASI
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('${report.latitude}, ${report.longitude}'),
                      ],
                    ),

                    SizedBox(height: 8),

                    // TANGGAL
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Dilaporkan: ${report.createdAt}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ✅ TAMBAHAN: Tampilkan indikator jika selesai
            if (report.status == 'completed') ...[
              SizedBox(height: 20),
              Card(
                color: Colors.green.withOpacity(0.1),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Laporan ini sudah ditandai selesai',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
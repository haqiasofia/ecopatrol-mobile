import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/db_helper.dart';
import '../models/model_report.dart';

// StateNotifier untuk mengelola daftar laporan (walaupun Mhs 2 hanya fokus insert)
class ReportNotifier extends StateNotifier<List<ReportModel>> {
  ReportNotifier() : super([]);

  // Fungsi CREATE (Fokus utama Mahasiswa 2)
  Future<bool> addReport(ReportModel report) async {
    try {
      final id = await DBHelper.instance.insertReport(report);
      if (id > 0) {
        // Jika berhasil, tambahkan laporan baru ke state dan kembalikan true
        final newReport = report;
        newReport.id = id;
        state = [newReport, ...state];
        return true;
      }
      return false;
    } catch (e) {
      print("Error inserting report: $e");
      return false;
    }
  }

  // Fungsi READ (Hanya untuk kelengkapan, fokus Mhs 2 adalah insert)
  Future<void> loadReports() async {
    final reports = await DBHelper.instance.getAllReports();
    state = reports;
  }

// Mahasiswa lain akan implementasi Update & Delete
}

// Provider yang akan digunakan di UI
final reportProvider =
StateNotifierProvider<ReportNotifier, List<ReportModel>>((ref) {
  return ReportNotifier();
});

// FutureProvider untuk memuat data di awal (opsional)
final reportListProvider = FutureProvider<List<ReportModel>>((ref) async {
  return DBHelper.instance.getAllReports();
});
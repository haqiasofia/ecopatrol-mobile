import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/model_report.dart';
import '../providers/report_providers.dart';
import '../database/db_helper.dart';

class EditReportScreen extends ConsumerStatefulWidget {
  final int reportId;
  const EditReportScreen({Key? key, required this.reportId}) : super(key: key);

  @override
  _EditReportScreenState createState() => _EditReportScreenState();
}

class _EditReportScreenState extends ConsumerState<EditReportScreen> {
  final _descController = TextEditingController();
  File? _workImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _workImage = File(picked.path);
      });
    }
  }

  Future<void> _markAsCompleted() async {
    if (_descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi deskripsi pekerjaan')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Ambil report saat ini
      final reports = ref.watch(reportProvider);
      final report = reports.firstWhere((r) => r.id == widget.reportId);

      // Buat deskripsi baru dengan info pekerjaan
      final newDescription = '''${report.description}
      
=== HASIL PENGERJAAN ===
Deskripsi: ${_descController.text}
Foto: ${_workImage?.path ?? 'Tidak ada foto'}
Tanggal Selesai: ${DateTime.now()}
Status: SELESAI''';

      // Update report
      final updatedReport = ReportModel(
        id: report.id,
        title: report.title,
        description: newDescription,  // Deskripsi diperbarui
        photoPath: report.photoPath,
        latitude: report.latitude,
        longitude: report.longitude,
        status: 'completed',  // Status diubah
        createdAt: report.createdAt,
      );

      // Simpan ke database
      final success = await DBHelper.instance.updateReport(updatedReport) > 0;

      if (success && mounted) {
        // Refresh data
        ref.read(reportProvider.notifier).loadReports();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Laporan selesai dengan deskripsi pekerjaan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteReport() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Laporan'),
        content: Text('Yakin ingin menghapus laporan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);

      try {
        final success = await DBHelper.instance.deleteReport(widget.reportId) > 0;

        if (success && mounted) {
          ref.read(reportProvider.notifier).loadReports();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Laporan dihapus!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(reportProvider);
    final report = reports.firstWhere(
          (r) => r.id == widget.reportId,
      orElse: () => throw Exception('Report not found'),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Tandai Selesai & Hapus')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            // INFO LAPORAN
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.title,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(report.description.length > 100
                        ? '${report.description.substring(0, 100)}...'
                        : report.description),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: report.status == 'completed'
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Status: ${report.status.toUpperCase()}',
                        style: TextStyle(
                          color: report.status == 'completed' ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // FORM JIKA MASIH PENDING
            if (report.status == 'pending') ...[
              Text('Tandai sebagai Selesai',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              SizedBox(height: 16),

              // DESKRIPSI PEKERJAAN
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Pekerjaan*',
                  hintText: 'Apa yang sudah dilakukan?',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 16),

              // FOTO HASIL
              Text('Foto Hasil (Opsional)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _workImage != null
                      ? Image.file(_workImage!, fit: BoxFit.cover)
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                      Text('Tap untuk pilih foto'),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // TOMBOL TANDAI SELESAI
              ElevatedButton(
                onPressed: _isLoading ? null : _markAsCompleted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Tandai Selesai',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),

              SizedBox(height: 16),
            ],

            // TOMBOL HAPUS
            OutlinedButton(
              onPressed: _isLoading ? null : _deleteReport,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red),
                minimumSize: Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Hapus Laporan',
                  style: TextStyle(color: Colors.red, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
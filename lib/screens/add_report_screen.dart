import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import '../models/model_report.dart';
import '../providers/report_providers.dart';

class AddReportScreen extends ConsumerStatefulWidget {
  const AddReportScreen({super.key});

  @override
  ConsumerState<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends ConsumerState<AddReportScreen> {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  File? selectedImage;
  double? latitude;
  double? longitude;

  final picker = ImagePicker();

  // -------------------------
  // AMBIL FOTO DARI CAMERA
  // -------------------------
  Future<void> pickFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  // -------------------------
  // AMBIL FOTO DARI GALERI
  // -------------------------
  Future<void> pickFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  // -------------------------
  // AMBIL LOKASI GPS
  // -------------------------
  Future<void> getCurrentLocation() async {
    bool permission = await _handleLocationPermission();
    if (!permission) return;

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      latitude = pos.latitude;
      longitude = pos.longitude;
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS belum aktif, nyalakan dulu')),
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin lokasi ditolak')),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin lokasi permanen ditolak')),
      );
      return false;
    }

    return true;
  }

  // -------------------------
  // SIMPAN LAPORAN KE DATABASE
  // -------------------------
  Future<void> _saveReport() async {
    if (titleCtrl.text.isEmpty ||
        descCtrl.text.isEmpty ||
        selectedImage == null ||
        latitude == null ||
        longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data terlebih dahulu')),
      );
      return;
    }

    final newReport = ReportModel(
      title: titleCtrl.text,
      description: descCtrl.text,
      photoPath: selectedImage!.path,
      latitude: latitude!,
      longitude: longitude!,
      status: "pending",
      createdAt: DateTime.now().toIso8601String(),
    );

    await ref.read(reportProvider.notifier).addReport(newReport);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Laporan berhasil disimpan!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Laporan Baru"),
        backgroundColor: Colors.green,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------------
            // INPUT JUDUL
            // -------------------------
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: "Judul Laporan",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // -------------------------
            // INPUT DESKRIPSI
            // -------------------------
            TextField(
              controller: descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Deskripsi",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // -------------------------
            // FOTO PREVIEW
            // -------------------------
            if (selectedImage != null)
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.file(selectedImage!, fit: BoxFit.cover),
              ),

            // -------------------------
            // BUTTON CAMERA & GALERI
            // -------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: pickFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Kamera"),
                ),
                ElevatedButton.icon(
                  onPressed: pickFromGallery,
                  icon: const Icon(Icons.photo),
                  label: const Text("Galeri"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // -------------------------
            // KOORDINAT
            // -------------------------
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: getCurrentLocation,
                  icon: const Icon(Icons.location_on),
                  label: const Text("Tag Lokasi"),
                ),
                const SizedBox(width: 10),
                if (latitude != null)
                  Text(
                    "(${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)})",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
              ],
            ),

            const SizedBox(height: 30),

            // -------------------------
            // BUTTON SIMPAN
            // -------------------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.all(14),
                ),
                child: const Text("Simpan Laporan"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

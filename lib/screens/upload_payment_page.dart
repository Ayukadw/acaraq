import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
//import 'qr_code_page.dart'; // Import halaman QR

class UploadPaymentPage extends StatefulWidget {
  final Event event;

  const UploadPaymentPage({Key? key, required this.event}) : super(key: key);

  @override
  _UploadPaymentPageState createState() => _UploadPaymentPageState();
}

class _UploadPaymentPageState extends State<UploadPaymentPage> {
  File? _image;
  final _picker = ImagePicker();

  // Fungsi untuk memilih gambar
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Fungsi untuk mengunggah gambar dan menyimpan status pembayaran
  Future<void> _uploadImage() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gambar terlebih dahulu!')),
      );
      return;
    }

    // Menyimpan bukti pembayaran dan menandakan status "paid" di SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      'paid_event_${widget.event.id!}',
      true,
    ); // Menandakan pembayaran telah dilakukan

    // Menampilkan notifikasi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bukti pembayaran berhasil diunggah!')),
    );

    // Setelah upload berhasil, langsung return true ke EventDetailPage untuk mengupdate statusnya
    Navigator.pop(context, true); // Mengirimkan data ke halaman sebelumnya
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Bukti Pembayaran'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _image == null
                ? const Text('Pilih bukti pembayaran (gambar)')
                : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _image!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo),
                  label: const Text('Galeri'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Kamera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _uploadImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Unggah Bukti Pembayaran'),
            ),
          ],
        ),
      ),
    );
  }
}

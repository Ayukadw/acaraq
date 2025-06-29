import 'dart:io';
import 'package:acaraq/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../providers/auth_provider.dart';
import '../../utils/db_helper.dart';

class UploadPaymentPage extends StatefulWidget {
  final Event event;

  const UploadPaymentPage({Key? key, required this.event}) : super(key: key);

  @override
  _UploadPaymentPageState createState() => _UploadPaymentPageState();
}

class _UploadPaymentPageState extends State<UploadPaymentPage> {
  File? _image;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gambar terlebih dahulu!')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final username = authProvider.user?.username ?? "Guest";
    final userId = authProvider.user?.id ?? 0;

    if (userId == 0 || username == "Guest") {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User tidak valid!')));
      return;
    }

    // Update status paid di SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('paid_event_${widget.event.id!}_${username}', true);

    // Simpan ke tabel payments di database
    await DBHelper.instance.insertPayment(userId, widget.event.id!);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bukti pembayaran berhasil diunggah!')),
    );

    Navigator.pop(
      context,
      true,
    ); // Kembali ke EventDetailPage dengan status sukses
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Bukti Pembayaran'),
        backgroundColor:
            themeProvider.isDarkMode
                ? const Color(0xFF58018B)
                : const Color(0xFFECCBFF),
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
                  icon: Icon(
                    Icons.photo,
                    color:
                        themeProvider.isDarkMode
                            ? Color(0xFF58018B)
                            : Color(0xFFFFC100),
                  ),
                  label: Text(
                    'Galeri',
                    style: TextStyle(
                      color:
                          themeProvider.isDarkMode
                              ? Color(0xFF58018B)
                              : Color(0xFFFFC100),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        themeProvider.isDarkMode
                            ? Color(0xFFFFC100)
                            : Color(0xFF58018B),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: Icon(
                    Icons.camera_alt,
                    color:
                        themeProvider.isDarkMode
                            ? Color(0xFF58018B)
                            : Color(0xFFFFC100),
                  ),
                  label: Text(
                    'Kamera',
                    style: TextStyle(
                      color:
                          themeProvider.isDarkMode
                              ? Color(0xFF58018B)
                              : Color(0xFFFFC100),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        themeProvider.isDarkMode
                            ? Color(0xFFFFC100)
                            : Color(0xFF58018B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _uploadImage,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    themeProvider.isDarkMode
                        ? Color(0xFFFFC100)
                        : Color(0xFF58018B),
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(
                'Unggah Bukti Pembayaran',
                style: TextStyle(
                  color:
                      themeProvider.isDarkMode
                          ? Color(0xFF58018B)
                          : Color(0xFFFFC100),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

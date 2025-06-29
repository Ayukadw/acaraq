import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/event.dart';
import 'upload_payment_page.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart'; // Import auth_provider untuk mengambil username

class EventDetailPage extends StatefulWidget {
  final Event event;

  const EventDetailPage({Key? key, required this.event}) : super(key: key);

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool isPaid = false;

  @override
  void initState() {
    super.initState();
    _checkPaymentStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkPaymentStatus(); // Tambahkan ini supaya reload saat kembali
  }

  Future<void> _checkPaymentStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final paid = prefs.getBool('paid_event_${widget.event.id!}') ?? false;
    setState(() {
      isPaid = paid;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Dapatkan username pengguna yang sedang login
    final username = authProvider.user?.username ?? "Guest";

    return Scaffold(
      backgroundColor:
          themeProvider.isDarkMode
              ? const Color(0xFF58018B)
              : const Color(0xFFECCBFF),
      appBar: AppBar(
        title: const Text('Detail Acara'),
        backgroundColor:
            themeProvider.isDarkMode ? const Color(0xFF58018B) : Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.event.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? Colors.white : Colors.orange,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child:
                  widget.event.imageUrl != null
                      ? (widget.event.imageUrl!.startsWith('http')
                          ? Image.network(
                            widget.event.imageUrl!,
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                          : Image.file(
                            File(widget.event.imageUrl!),
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          ))
                      : Container(
                        width: double.infinity,
                        height: 150,
                        color: Colors.grey,
                        child: const Icon(Icons.image, color: Colors.white),
                      ),
            ),
            const SizedBox(height: 8),
            Text('${widget.event.date} • ${widget.event.time}'),
            const SizedBox(height: 8),
            Text(widget.event.description),
            const SizedBox(height: 16),
            const Text(
              "Lokasi Acara:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(widget.event.location),
            const SizedBox(height: 16),
            const Text(
              "Tuan Rumah:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(widget.event.hostName),
            const SizedBox(height: 24),
            if (isPaid) ...[
              const Text(
                "QR Code untuk Check-In:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Center(
                child: QrImageView(
                  data: username, // Menggunakan username yang sedang login
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
            ] else ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => UploadPaymentPage(event: widget.event),
                    ),
                  );
                  if (result == true) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('paid_event_${widget.event.id!}', true);
                    _checkPaymentStatus();
                  }
                },
                child: const Text('Unggah Bukti Pembayaran'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

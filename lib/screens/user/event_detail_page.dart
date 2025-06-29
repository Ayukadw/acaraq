import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/event.dart';
import 'upload_payment_page.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import 'dart:convert';

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

  Future<void> _checkPaymentStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final username = authProvider.user?.username ?? "Guest";

    final prefs = await SharedPreferences.getInstance();
    final paid =
        prefs.getBool('paid_event_${widget.event.id!}_$username') ?? false;
    setState(() {
      isPaid = paid;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final username = authProvider.user?.username ?? "Guest";

    final qrData = jsonEncode({
      'event_id': widget.event.id,
      'username': username,
    });

    return Scaffold(
      backgroundColor:
          themeProvider.isDarkMode
              ? const Color(0xFF58018B)
              : const Color(0xFFECCBFF),
      appBar: AppBar(
        title: const Text('Detail Acara'),
        backgroundColor:
            themeProvider.isDarkMode ? Color(0xFF58018B) : Color(0xFFECCBFF),
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
                color:
                    themeProvider.isDarkMode
                        ? Color(0xFFFFC100)
                        : Color(0xFF58018B),
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
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
            ] else ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      themeProvider.isDarkMode
                          ? Color(0xFFFFC100)
                          : Color(0xFF58018B),
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
                    await prefs.setBool(
                      'paid_event_${widget.event.id!}_$username',
                      true,
                    );
                    _checkPaymentStatus();
                  }
                },
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
          ],
        ),
      ),
    );
  }
}

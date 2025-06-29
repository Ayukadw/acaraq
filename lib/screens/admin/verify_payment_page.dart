import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../models/checkin_log.dart';

class VerifyPaymentPage extends StatelessWidget {
  final File paymentImage;
  final String guestName;
  final String eventTitle;
  final int eventId;
  final int guestId; // ID Pengunjung

  const VerifyPaymentPage({
    Key? key,
    required this.paymentImage,
    required this.guestName,
    required this.eventTitle,
    required this.eventId,
    required this.guestId,
  }) : super(key: key);

  Future<void> _verifyPayment(BuildContext context) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    // Simulasi memverifikasi bukti pembayaran dan menyimpan statusnya
    await Future.delayed(const Duration(seconds: 2));

    // Update status pembayaran sebagai terverifikasi
    eventProvider.addCheckIn(
      CheckInLog(
        eventId: eventId,
        guestName: guestName,
        checkinTime: DateTime.now().toString(), // Waktu check-in
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bukti pembayaran terverifikasi!')),
    );

    // Aksi setelah verifikasi berhasil
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Bukti Pembayaran'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'Acara: $eventTitle',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Pengunjung: $guestName',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Bukti Pembayaran:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Image.file(
              paymentImage,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _verifyPayment(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Verifikasi Pembayaran'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Logika untuk menolak pembayaran bisa ditambahkan di sini
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Tolak Pembayaran'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; // Untuk JSON encoding dan decoding
import '../../models/checkin_log.dart';
import '../../providers/event_provider.dart';
import 'visitor_list_page.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({Key? key}) : super(key: key);

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  String scannedText = '';

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final code = barcode.rawValue;
      if (code != null && scannedText != code) {
        setState(() => scannedText = code);

        // Coba decode QR yang berisi JSON
        try {
          final data = jsonDecode(code);
          final eventId = data['event_id'];
          final username = data['username'];

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('QR ditemukan: Event $eventId - User $username'),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('QR tidak valid')));
        }
      }
    }
  }

  Future<void> _handleCheckIn() async {
    if (scannedText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('QR code tidak valid.')));
      return;
    }

    // Decode QR
    final data = jsonDecode(scannedText);
    final eventId = data['event_id'];
    final username = data['username'];

    if (eventId == null || username == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data QR code tidak lengkap.')),
      );
      return;
    }

    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    final now = DateTime.now();
    final checkinTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    // Tambahkan log check-in
    await eventProvider.addCheckIn(
      CheckInLog(
        eventId: eventId,
        guestName: username,
        checkinTime: checkinTime,
      ),
    );

    // Pindah ke VisitorListPage khusus untuk eventId ini
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => VisitorListPage(eventId: eventId)),
    );

    setState(() {
      scannedText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color containerColor =
        isDarkMode ? const Color(0xFF8240A8) : Colors.white;
    final Color textColor = isDarkMode ? Color(0xFFFFC100) : Color(0xFF58018B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor:
            isDarkMode ? const Color(0xFF58018B) : Color(0xFFECCBFF),
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: MobileScannerController(
                facing: CameraFacing.back,
                torchEnabled: false,
              ),
              onDetect: _onDetect,
            ),
          ),
          if (scannedText.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hasil Scan: $scannedText',
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Tandai Check-In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC100),
                      foregroundColor: const Color(0xFF58018B),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _handleCheckIn,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

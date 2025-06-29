import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../models/checkin_log.dart';
import '../providers/event_provider.dart';
import 'visitor_list_page.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({Key? key}) : super(key: key);

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  String scannedText = ''; // This will hold the scanned username

  // When QR is detected
  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final code = barcode.rawValue;
      if (code != null && scannedText != code) {
        setState(
          () => scannedText = code,
        ); // Store the scanned QR code value (username)

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('QR Ditemukan: $code')),
        ); // Show QR feedback
      }
    }
  }

  // Now when admin clicks 'Tandai Check-In', they should be logged with username
  Future<void> _handleCheckIn() async {
    if (scannedText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('QR code tidak valid.')));
      return;
    }

    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    final guestName = scannedText; // Use the scanned username from QR code

    final now = DateTime.now();
    final checkinTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    // Add the check-in log with guestName (which is the username)
    await eventProvider.addCheckIn(
      CheckInLog(
        guestName: guestName, // Store the scanned username here
        checkinTime: checkinTime,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const VisitorListPage(),
      ), // No need for eventId, just show the list
    );

    setState(() {
      scannedText = ''; // Reset scanned text after check-in
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color containerColor =
        isDarkMode ? const Color(0xFF8240A8) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF58018B);
    final Color titleColor =
        isDarkMode ? const Color(0xFFFFC100) : const Color(0xFF58018B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: isDarkMode ? const Color(0xFF58018B) : Colors.orange,
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
                    'Hasil Scan: $scannedText', // Display the scanned username
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
                    onPressed:
                        _handleCheckIn, // Handle the check-in with the username
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

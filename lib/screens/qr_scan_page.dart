import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
        // Lakukan logika check-in atau pindah halaman
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('QR Ditemukan: $code')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.orange,
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Hasil: $scannedText',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
        ],
      ),
    );
  }
}

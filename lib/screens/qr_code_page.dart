import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/event.dart';
import '../providers/theme_provider.dart';

class QRCodePage extends StatelessWidget {
  final Event event;

  const QRCodePage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final Color bgColor =
        themeProvider.isDarkMode
            ? const Color(0xFF58018B)
            : const Color(0xFFECCBFF);
    final Color cardColor =
        themeProvider.isDarkMode
            ? const Color(0xFFFFC100)
            : const Color(0xFF58018B);
    final Color textColor =
        themeProvider.isDarkMode
            ? const Color(0xFFFFC100)
            : const Color(0xFF58018B);
    final Color iconColor =
        themeProvider.isDarkMode
            ? const Color(0xFFFFC100)
            : const Color(0xFF58018B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'QR Code',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              'Mohon tunjukkan QR Code berikut\npada panitia saat masuk.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: QrImageView(
                data: event.id!.toString(),
                version: QrVersions.auto,
                size: 200.0,
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          color:
                              themeProvider.isDarkMode
                                  ? const Color(0xFF58018B)
                                  : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        event.date,
                        style: TextStyle(
                          color:
                              themeProvider.isDarkMode
                                  ? const Color(0xFF58018B)
                                  : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.location,
                    style: TextStyle(
                      color:
                          themeProvider.isDarkMode
                              ? const Color(0xFF58018B)
                              : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../providers/theme_provider.dart';
import 'home_page.dart'; // Import HomePage

class VisitorListPage extends StatefulWidget {
  const VisitorListPage({Key? key}) : super(key: key);

  @override
  _VisitorListPageState createState() => _VisitorListPageState();
}

class _VisitorListPageState extends State<VisitorListPage> {
  @override
  void initState() {
    super.initState();
    // Load all check-in logs
    Provider.of<EventProvider>(context, listen: false).loadCheckInLogsAll();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final Color textColor =
        themeProvider.isDarkMode
            ? const Color(0xFFFFC100)
            : const Color(0xFF58018B);
    final Color backgroundColor =
        themeProvider.isDarkMode
            ? const Color(0xFF58018B)
            : const Color(0xFFECCBFF);
    final Color cardColor =
        themeProvider.isDarkMode ? const Color(0xFF8240A8) : Colors.white;
    final Color headerColor =
        themeProvider.isDarkMode
            ? const Color(0xFFFFC100)
            : const Color(0xFF58018B);

    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final logs = eventProvider.checkInLogs;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            title: Text(
              'Daftar Pengunjung',
              style: TextStyle(color: headerColor, fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: headerColor),
              onPressed: () {
                // Navigasi kembali ke HomePage dan hapus semua halaman sebelumnya
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (Route<dynamic> route) =>
                      false, // Hapus semua halaman sebelumnya
                );
              },
            ),
          ),
          body:
              logs.isEmpty
                  ? Center(
                    child: Text(
                      'Belum ada pengunjung yang check-in.',
                      style: TextStyle(color: textColor),
                    ),
                  )
                  : Column(
                    children: [
                      // Header bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Username',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: headerColor,
                              ),
                            ),
                            Text(
                              'Check-in',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: headerColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final log = logs[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  if (!themeProvider.isDarkMode)
                                    BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(0, 3),
                                      blurRadius: 5,
                                    ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 12.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      log.guestName, // Display username from scanned QR code
                                      style: TextStyle(
                                        color:
                                            themeProvider.isDarkMode
                                                ? Colors.white
                                                : const Color(0xFF58018B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      log.checkinTime, // Display check-in time
                                      style: TextStyle(
                                        color:
                                            themeProvider.isDarkMode
                                                ? Colors.white
                                                : const Color(0xFF58018B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
        );
      },
    );
  }
}

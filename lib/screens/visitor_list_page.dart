import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../providers/theme_provider.dart';
import '../models/checkin_log.dart';
import 'home_page.dart';

class VisitorListPage extends StatefulWidget {
  final int eventId;

  const VisitorListPage({Key? key, required this.eventId}) : super(key: key);

  @override
  _VisitorListPageState createState() => _VisitorListPageState();
}

class _VisitorListPageState extends State<VisitorListPage> {
  @override
  void initState() {
    super.initState();
    // Load check-in logs khusus eventId
    Provider.of<EventProvider>(
      context,
      listen: false,
    ).loadCheckInLogs(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final logs = eventProvider.checkInLogs;

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
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (Route<dynamic> route) => false,
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
                                      log.guestName,
                                      style: TextStyle(
                                        color:
                                            themeProvider.isDarkMode
                                                ? Colors.white
                                                : const Color(0xFF58018B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      log.checkinTime,
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

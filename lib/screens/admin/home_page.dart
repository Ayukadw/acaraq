import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/event_provider.dart';
import 'add_edit_event_page.dart';
import 'qr_scan_page.dart';
import 'settings_page.dart';
import 'visitor_list_page.dart'; // Pastikan visitor_list_page diimport

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load data events saat pertama masuk
    Future.microtask(() {
      Provider.of<EventProvider>(context, listen: false).loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final username = authProvider.user?.username ?? 'Admin';

    final Color textColor =
        themeProvider.isDarkMode
            ? const Color(0xFFFFC100)
            : const Color(0xFF58018B);
    final Color cardColor =
        themeProvider.isDarkMode
            ? const Color(0xFFFFC100)
            : const Color(0xFF58018B);
    final Color navBgColor =
        themeProvider.isDarkMode
            ? const Color(0xFF69147D)
            : const Color(0xFFDDB7F3);
    final Color navIconColor =
        themeProvider.isDarkMode
            ? const Color(0xFFFFC100)
            : const Color(0xFF58018B);
    final Color scaffoldBgColor =
        themeProvider.isDarkMode
            ? const Color(0xFF58018B)
            : const Color(0xFFECCBFF);

    final pages = [
      _buildEventList(context, themeProvider, username, textColor, cardColor),
      const QRScanPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: pages[_currentIndex],
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton(
                backgroundColor:
                    themeProvider.isDarkMode
                        ? const Color(0xFFFFC100)
                        : const Color(0xFF58018B),
                child: Icon(
                  Icons.add,
                  color:
                      themeProvider.isDarkMode
                          ? const Color(0xFF58018B)
                          : const Color(0xFFFFC100),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddEditEventPage()),
                  ).then((_) {
                    Provider.of<EventProvider>(
                      context,
                      listen: false,
                    ).loadEvents();
                  });
                },
              )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: navBgColor,
        selectedItemColor: navIconColor,
        unselectedItemColor: navIconColor.withOpacity(0.5),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan QR',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildEventList(
    BuildContext context,
    ThemeProvider themeProvider,
    String username,
    Color textColor,
    Color cardColor,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, $username',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Mari kelola acaramu agar terstruktur!',
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 22,
                  backgroundColor:
                      themeProvider.isDarkMode
                          ? const Color(0xFFFFC100)
                          : const Color(0xFF58018B),
                  child: Icon(
                    Icons.person,
                    color:
                        themeProvider.isDarkMode
                            ? const Color(0xFF58018B)
                            : const Color(0xFFFFC100),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Acara yang akan Datang',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: Consumer<EventProvider>(
                builder: (context, eventProvider, _) {
                  final events = eventProvider.events;
                  if (events.isEmpty) {
                    return const Center(child: Text('Tidak ada acara.'));
                  }

                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditEventPage(event: event),
                            ),
                          ).then((_) {
                            Provider.of<EventProvider>(
                              context,
                              listen: false,
                            ).loadEvents();
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                child:
                                    event.imageUrl != null
                                        ? (event.imageUrl!.startsWith('http')
                                            ? Image.network(
                                              event.imageUrl!,
                                              width: double.infinity,
                                              height: 150,
                                              fit: BoxFit.cover,
                                            )
                                            : Image.file(
                                              File(event.imageUrl!),
                                              key: UniqueKey(),
                                              width: double.infinity,
                                              height: 150,
                                              fit: BoxFit.cover,
                                            ))
                                        : Container(
                                          width: double.infinity,
                                          height: 150,
                                          color: Colors.grey,
                                          child: const Icon(
                                            Icons.image,
                                            color: Colors.white,
                                          ),
                                        ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            event.title,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  themeProvider.isDarkMode
                                                      ? Color(0xFF58018B)
                                                      : Color(0xFFFFC100),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          event.date,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                themeProvider.isDarkMode
                                                    ? Color(0xFF58018B)
                                                    : Color(0xFFFFC100),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Text(
                                          event.location,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                themeProvider.isDarkMode
                                                    ? Color(0xFF58018B)
                                                    : Color(0xFFFFC100),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Tombol List Pengunjung di tengah
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        themeProvider.isDarkMode
                                            ? Color(0xFF58018B)
                                            : Color(0xFFECCBFF),
                                    foregroundColor:
                                        themeProvider.isDarkMode
                                            ? Color(0xFFFFC100)
                                            : Color(0xFF58018B),
                                    minimumSize: Size(double.infinity, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => VisitorListPage(
                                              eventId: event.id!,
                                            ),
                                      ),
                                    );
                                  },
                                  child: const Text('List Pengunjung'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

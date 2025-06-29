import 'dart:io';
import 'package:acaraq/screens/user/event_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/event.dart';
import '../../utils/db_helper.dart';
import 'user_profile_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({Key? key}) : super(key: key);

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final username = authProvider.user?.username ?? 'User';

    final Color textColor =
        themeProvider.isDarkMode
            ? const Color(0xFFD9D9D9)
            : const Color(0xFF000000);
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

    return Scaffold(
      backgroundColor:
          themeProvider.isDarkMode
              ? const Color(0xFF58018B)
              : const Color(0xFFECCBFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER dibungkus Row supaya sejajar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
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
                        const SizedBox(height: 5),
                        Text(
                          'Mari jelajahi acara-acara yang ada!',
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
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
                child: FutureBuilder<List<Event>>(
                  future: DBHelper.instance.getAllEvents(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(child: Text('Terjadi kesalahan'));
                    }

                    final events = snapshot.data ?? [];

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
                                builder:
                                    (context) => EventDetailPage(event: event),
                              ),
                            );
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                        ? const Color(
                                                          0xFF000000,
                                                        )
                                                        : Colors.white,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            event.date,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  themeProvider.isDarkMode
                                                      ? const Color(0xFF000000)
                                                      : Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            event.location,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  themeProvider.isDarkMode
                                                      ? const Color(0xFF000000)
                                                      : Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: navBgColor,
        selectedItemColor: navIconColor,
        unselectedItemColor: navIconColor.withOpacity(0.5),
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UserProfilePage()),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

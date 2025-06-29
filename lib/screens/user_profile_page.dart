import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final username = authProvider.user?.username ?? 'User';

    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF58018B) : const Color(0xFFECCBFF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profil',
          style: TextStyle(
            color:
                isDarkMode ? const Color(0xFFFFC100) : const Color(0xFF58018B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color:
                  isDarkMode
                      ? const Color(0xFFFFC100)
                      : const Color(0xFF58018B),
            ),
            onPressed: () async {
              await authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor:
                  isDarkMode
                      ? const Color(0xFFFFC100)
                      : const Color(0xFF58018B),
              child: Icon(
                Icons.person,
                size: 60,
                color:
                    isDarkMode
                        ? const Color(0xFF58018B)
                        : const Color(0xFFFFC100),
              ),
            ),
            const SizedBox(height: 32),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Nama Akun :',
                style: TextStyle(
                  color: isDarkMode ? const Color(0xFFD9D9D9) : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF8240A8) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 3),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    color:
                        isDarkMode
                            ? const Color(0xFFFFC100)
                            : const Color(0xFF58018B),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      username,
                      style: TextStyle(
                        color:
                            isDarkMode ? const Color(0xFFD9D9D9) : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tema :',
                style: TextStyle(
                  color: isDarkMode ? const Color(0xFFD9D9D9) : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF8240A8) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 3),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.brightness_4,
                    color:
                        isDarkMode
                            ? const Color(0xFFFFC100)
                            : const Color(0xFF58018B),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Tema Gelap', style: TextStyle(fontSize: 16)),
                  ),
                  Switch(
                    value: isDarkMode,
                    activeColor: const Color(0xFFFFC100),
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor:
            isDarkMode ? const Color(0xFFFFC100) : const Color(0xFF58018B),
        unselectedItemColor: Colors.grey,
        backgroundColor:
            isDarkMode ? const Color(0xFF69147D) : const Color(0xFFDDB7F3),
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/user_home');
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color:
                  isDarkMode
                      ? const Color(0xFFFFC100)
                      : const Color(0xFF58018B),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color:
                  isDarkMode
                      ? const Color(0xFFFFC100)
                      : const Color(0xFF58018B),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

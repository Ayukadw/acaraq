import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/event_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/db_helper.dart'; // Pastikan untuk mengimpor DBHelper
import 'screens/user_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Memastikan inisialisasi widget

  // Menghapus database lama jika diperlukan
  await DBHelper.instance.deleteDatabaseFile();

  // Hapus SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  runApp(const EventApp());
}

class EventApp extends StatelessWidget {
  const EventApp({Key? key}) : super(key: key);

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Manajemen Acara',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness:
                  themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
              primaryColor:
                  themeProvider.isDarkMode
                      ? const Color(
                        0xFFFFC100,
                      ) // Dark Mode - Orange (primary color)
                      : const Color(
                        0xFF58018B,
                      ), // Light Mode - Purple (primary color)
              scaffoldBackgroundColor:
                  themeProvider.isDarkMode
                      ? const Color(0xFF58018B) // Dark Mode Background
                      : const Color(0xFFECCBFF), // Light Mode Background
              appBarTheme: AppBarTheme(
                backgroundColor:
                    themeProvider.isDarkMode
                        ? const Color(0xFF58018B) // Dark Mode AppBar
                        : const Color(0xFF58018B), // Light Mode AppBar
                elevation: 0,
              ),
              textTheme: TextTheme(
                titleMedium: TextStyle(
                  color:
                      themeProvider.isDarkMode
                          ? const Color(0xFFD9D9D9)
                          : const Color(0xFF000000),
                  fontWeight: FontWeight.bold,
                ),
                bodyLarge: TextStyle(
                  color:
                      themeProvider.isDarkMode
                          ? const Color(0xFFD9D9D9)
                          : const Color(0xFF000000),
                ),
              ),
              buttonTheme: ButtonThemeData(
                buttonColor:
                    themeProvider.isDarkMode
                        ? const Color(0xFFFFC100) // Dark Mode - Yellow Button
                        : const Color(0xFFFFC100), // Light Mode - Yellow Button
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor:
                    themeProvider.isDarkMode
                        ? const Color(0xFF8240A8) // Dark Mode Input background
                        : Colors.white, // Light Mode Input background
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              useMaterial3: true,
            ),
            home: FutureBuilder<bool>(
              future: _checkLoginStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen();
                } else {
                  return snapshot.data == true
                      ? const HomePage()
                      : const LoginPage();
                }
              },
            ),
            routes: {
              '/login': (_) => const LoginPage(),
              '/register': (_) => const RegisterPage(),
              '/home': (_) => const HomePage(),
              '/user_home': (_) => const UserHomePage(),
            },
          );
        },
      ),
    );
  }
}

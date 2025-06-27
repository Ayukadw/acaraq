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

void main() {
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
              primarySwatch: Colors.orange,
              useMaterial3: true,
            ),
            home: FutureBuilder<bool>(
              future: _checkLoginStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen();
                } else {
                  return snapshot.data == true ? const HomePage() : const LoginPage();
                }
              },
            ),
            routes: {
              '/login': (_) => const LoginPage(),
              '/register': (_) => const RegisterPage(),
              '/home': (_) => const HomePage(),
            },
          );
        },
      ),
    );
  }
}

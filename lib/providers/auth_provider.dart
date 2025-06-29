import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/db_helper.dart';

class AuthProvider with ChangeNotifier {
  User? _user;

  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.role == 'admin';
  User? get user => _user;

  // Fungsi untuk registrasi user biasa (role default: user)
  Future<bool> register(String username, String password) async {
    final existingUser = await DBHelper.instance.getUserByUsername(username);
    if (existingUser != null) {
      return false; // Username sudah ada
    }

    final newUser = User(username: username, password: password, role: 'user');
    await DBHelper.instance.insertUser(newUser);
    return true;
  }

  // Fungsi login
  Future<void> login(String username, String password) async {
    final user = await DBHelper.instance.getUser(username, password);
    if (user != null) {
      _user = user;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username);
      await prefs.setString('role', user.role);

      notifyListeners();
    }
  }

  // Fungsi logout
  Future<void> logout() async {
    _user = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('username');
    await prefs.remove('role');

    notifyListeners();
  }

  // Fungsi auto-login
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final username = prefs.getString('username');
    final role = prefs.getString('role');

    if (isLoggedIn && username != null && role != null) {
      _user = User(username: username, password: '', role: role);
      notifyListeners();
    }
  }
}

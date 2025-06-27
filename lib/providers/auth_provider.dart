import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/db_helper.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool get isAuthenticated => _user != null;
  User? get user => _user;

  Future<bool> register(String username, String password) async {
    final existingUser = await DBHelper.instance.getUserByUsername(username);
    if (existingUser != null) {
      return false; // Username already exists
    }
    final newUser = User(username: username, password: password);
    await DBHelper.instance.insertUser(newUser);
    return true;
  }

  Future<void> login(String username, String password) async {
    final user = await DBHelper.instance.getUser(username, password);
    if (user != null) {
      _user = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('username');
    notifyListeners();
  }
}
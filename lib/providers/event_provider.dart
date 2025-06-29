import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/checkin_log.dart';
import '../utils/db_helper.dart';

class EventProvider with ChangeNotifier {
  List<Event> _events = [];
  List<CheckInLog> _checkInLogs = [];

  List<Event> get events => _events;
  List<CheckInLog> get checkInLogs => _checkInLogs;

  // Memuat data semua event dari database
  Future<void> loadEvents() async {
    _events = await DBHelper.instance.getAllEvents();
    notifyListeners();
  }

  // Memuat data check-in logs berdasarkan eventId
  Future<void> loadCheckInLogs(int eventId) async {
    _checkInLogs = await DBHelper.instance.getLogsByEvent(eventId);
    notifyListeners();
  }

  // Memuat semua data check-in logs dari semua event
  Future<void> loadCheckInLogsAll() async {
    _checkInLogs = await DBHelper.instance.getAllLogs();
    notifyListeners();
  }

  // Menambahkan event baru ke database
  Future<void> addEvent(Event event) async {
    await DBHelper.instance.insertEvent(event);
    await loadEvents();
  }

  // Memperbarui data event yang sudah ada
  Future<void> updateEvent(Event event) async {
    await DBHelper.instance.updateEvent(event);
    await loadEvents();
  }

  // Menghapus event berdasarkan ID
  Future<void> deleteEvent(int id) async {
    await DBHelper.instance.deleteEvent(id);
    await loadEvents();
  }

  // Menambahkan check-in log ke database
  Future<void> addCheckIn(CheckInLog log) async {
    await DBHelper.instance.insertCheckIn(log);
    await loadCheckInLogs(log.eventId!);
  }

  // Menghapus check-in log jika diperlukan
  Future<void> removeCheckIn(int logId, int eventId) async {
    await DBHelper.instance.deleteCheckInLog(logId);
    await loadCheckInLogs(eventId); // Reload logs after removing check-in
  }

  // Mengambil check-in log berdasarkan ID
  CheckInLog? getCheckInLogById(int id) {
    try {
      return _checkInLogs.firstWhere((log) => log.id == id);
    } catch (_) {
      return null;
    }
  }

  // Fungsi untuk mengecek apakah user sudah membayar untuk event tertentu
  Future<bool> isUserPaidForEvent(int userId, int eventId) async {
    final isPaid = await DBHelper.instance.isPaidForEvent(userId, eventId);
    return isPaid;
  }

  // Fungsi untuk menambahkan pembayaran
  Future<void> addPayment(int userId, int eventId) async {
    await DBHelper.instance.insertPayment(userId, eventId);
    notifyListeners(); // Notify listeners after adding payment
  }
}

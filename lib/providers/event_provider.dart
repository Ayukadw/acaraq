import 'package:flutter/material.dart';
import '../models/event.dart';
import '../utils/db_helper.dart';

class EventProvider with ChangeNotifier {
  List<Event> _events = [];

  List<Event> get events => _events;

  Future<void> loadEvents() async {
    _events = await DBHelper.instance.getAllEvents();
    notifyListeners();
  }

  Future<void> addEvent(Event event) async {
    await DBHelper.instance.insertEvent(event);
    await loadEvents();
  }

  Future<void> updateEvent(Event event) async {
    await DBHelper.instance.updateEvent(event);
    await loadEvents();
  }

  Future<void> deleteEvent(int id) async {
    await DBHelper.instance.deleteEvent(id);
    await loadEvents();
  }
}
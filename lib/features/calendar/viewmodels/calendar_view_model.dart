import 'package:flutter/material.dart';
import 'package:chronus/features/calendar/models/calendar_event.dart';
import 'package:chronus/features/calendar/services/calendar_service.dart';

class CalendarViewModel extends ChangeNotifier {
  final CalendarService _calendarService;

  CalendarViewModel(this._calendarService) {
    _initializeSampleEvents();
  }

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  DateTime get selectedDate => _selectedDate;
  DateTime get focusedMonth => _focusedMonth;

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void changeMonth(int delta) {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    notifyListeners();
  }

  List<CalendarEvent> get allEvents => _calendarService.getAllEvents();

  List<CalendarEvent> get selectedDateEvents =>
      _calendarService.getEventsForDate(_selectedDate);

  List<CalendarEvent> get currentMonthEvents =>
      _calendarService.getEventsForMonth(_focusedMonth.year, _focusedMonth.month);

  bool hasEventsOnDate(DateTime date) {
    return _calendarService.hasEventsOnDate(date);
  }

  void createEvent({
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
    String? color,
  }) {
    _calendarService.createEvent(
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      color: color,
    );
    notifyListeners();
  }

  void updateEvent(
    String id, {
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? color,
  }) {
    final success = _calendarService.updateEvent(
      id,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      color: color,
    );
    if (success) {
      notifyListeners();
    }
  }

  void deleteEvent(String id) {
    final success = _calendarService.deleteEvent(id);
    if (success) {
      notifyListeners();
    }
  }

  CalendarEvent? getEventById(String id) {
    return _calendarService.getEventById(id);
  }

  // Initialize with some sample events
  void _initializeSampleEvents() {
    final now = DateTime.now();

    _calendarService.createEvent(
      title: 'Team Meeting',
      description: 'Weekly sync with the team',
      startTime: DateTime(now.year, now.month, now.day, 10, 0),
      endTime: DateTime(now.year, now.month, now.day, 11, 0),
      color: '#C98938',
    );

    _calendarService.createEvent(
      title: 'Lunch Break',
      description: 'Time to recharge',
      startTime: DateTime(now.year, now.month, now.day, 12, 0),
      endTime: DateTime(now.year, now.month, now.day, 13, 0),
      color: '#E5AD64',
    );

    _calendarService.createEvent(
      title: 'Project Review',
      description: 'Review Q4 progress',
      startTime: DateTime(now.year, now.month, now.day + 1, 14, 0),
      endTime: DateTime(now.year, now.month, now.day + 1, 15, 30),
      color: '#9A5F23',
    );
  }
}

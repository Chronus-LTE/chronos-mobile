import 'package:flutter/material.dart';
import 'package:chronus/features/calendar/models/calendar_event.dart';
import 'package:chronus/features/calendar/services/calendar_service.dart';

class CalendarViewModel extends ChangeNotifier {
  final CalendarService _calendarService;

  CalendarViewModel(this._calendarService) {
    _loadCurrentMonthEvents();
  }

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  List<CalendarEvent> _allEvents = [];
  bool _isLoading = false;
  String? _error;

  DateTime get selectedDate => _selectedDate;
  DateTime get focusedMonth => _focusedMonth;
  List<CalendarEvent> get allEvents => _allEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void changeMonth(int delta) {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    _loadCurrentMonthEvents();
    notifyListeners();
  }

  List<CalendarEvent> get selectedDateEvents {
    return _allEvents.where((event) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      final targetDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
      return eventDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  List<CalendarEvent> get currentMonthEvents {
    return _allEvents.where((event) {
      return event.startTime.year == _focusedMonth.year &&
          event.startTime.month == _focusedMonth.month;
    }).toList();
  }

  bool hasEventsOnDate(DateTime date) {
    return _allEvents.any((event) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      return eventDate.isAtSameMomentAs(targetDate);
    });
  }

  /// Load events for current month
  Future<void> _loadCurrentMonthEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final events = await _calendarService.getEventsForMonth(
        _focusedMonth.year,
        _focusedMonth.month,
      );
      _allEvents = events;
      _error = null;
    } catch (e) {
      _error = 'Failed to load events: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh events
  Future<void> refreshEvents() async {
    await _loadCurrentMonthEvents();
  }

  /// Create new event
  Future<bool> createEvent({
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
    String? color,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final event = await _calendarService.createEvent(
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        color: color,
      );

      if (event != null) {
        // Add to local list if it's in the current month
        if (event.startTime.year == _focusedMonth.year &&
            event.startTime.month == _focusedMonth.month) {
          _allEvents.add(event);
        }
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to create event';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to create event: $e';
      _isLoading = false;
      notifyListeners();
      print(_error);
      return false;
    }
  }

  /// Update existing event
  Future<bool> updateEvent(
    String id, {
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? color,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedEvent = await _calendarService.updateEvent(
        id,
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        color: color,
      );

      if (updatedEvent != null) {
        // Update in local list
        final index = _allEvents.indexWhere((event) => event.id == id);
        if (index != -1) {
          _allEvents[index] = updatedEvent;
        }
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to update event';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to update event: $e';
      _isLoading = false;
      notifyListeners();
      print(_error);
      return false;
    }
  }

  /// Delete event
  Future<bool> deleteEvent(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _calendarService.deleteEvent(id);

      if (success) {
        // Remove from local list
        _allEvents.removeWhere((event) => event.id == id);
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to delete event';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to delete event: $e';
      _isLoading = false;
      notifyListeners();
      print(_error);
      return false;
    }
  }

  CalendarEvent? getEventById(String id) {
    try {
      return _allEvents.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }
}

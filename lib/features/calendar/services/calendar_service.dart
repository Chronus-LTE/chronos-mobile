import 'package:chronus/features/calendar/models/calendar_event.dart';
import 'package:uuid/uuid.dart';

class CalendarService {
  final List<CalendarEvent> _events = [];
  final _uuid = const Uuid();

  // Create
  CalendarEvent createEvent({
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
    String? color,
  }) {
    final event = CalendarEvent(
      id: _uuid.v4(),
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      color: color ?? '#C98938',
    );
    _events.add(event);
    return event;
  }

  // Read
  List<CalendarEvent> getAllEvents() {
    return List.unmodifiable(_events);
  }

  List<CalendarEvent> getEventsForDate(DateTime date) {
    return _events.where((event) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      return eventDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  List<CalendarEvent> getEventsForMonth(int year, int month) {
    return _events.where((event) {
      return event.startTime.year == year && event.startTime.month == month;
    }).toList();
  }

  CalendarEvent? getEventById(String id) {
    try {
      return _events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update
  bool updateEvent(String id, {
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? color,
  }) {
    final index = _events.indexWhere((event) => event.id == id);
    if (index == -1) return false;

    final oldEvent = _events[index];
    _events[index] = oldEvent.copyWith(
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      color: color,
    );
    return true;
  }

  // Delete
  bool deleteEvent(String id) {
    final index = _events.indexWhere((event) => event.id == id);
    if (index == -1) return false;

    _events.removeAt(index);
    return true;
  }

  // Helper: Check if a date has events
  bool hasEventsOnDate(DateTime date) {
    return getEventsForDate(date).isNotEmpty;
  }
}

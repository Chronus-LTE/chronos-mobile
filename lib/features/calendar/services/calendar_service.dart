import 'dart:convert';
import 'package:chronus/features/calendar/models/calendar_event.dart';
import 'package:chronus/features/auth/services/auth_service.dart';
import 'package:http/http.dart' as http;

class CalendarService {
  final AuthService _authService;

  CalendarService(this._authService);

  String get _baseUrl => '${AuthService.baseUrl}/calendar/events';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authService.authToken != null)
          'Authorization': 'Bearer ${_authService.authToken}',
      };

  /// Convert backend response to CalendarEvent model
  CalendarEvent _mapResponseToEvent(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as String,
      title: json['summary'] as String,
      description: json['description'] as String?,
      startTime: DateTime.fromMillisecondsSinceEpoch(
        (json['start_timestamp'] as int) * 1000,
      ),
      endTime: DateTime.fromMillisecondsSinceEpoch(
        (json['end_timestamp'] as int) * 1000,
      ),
      color: '#C98938', // Default color, can be customized
    );
  }

  /// Convert CalendarEvent to backend request format
  Map<String, dynamic> _mapEventToRequest(CalendarEvent event) {
    return {
      'summary': event.title,
      'start_timestamp': event.startTime.millisecondsSinceEpoch ~/ 1000,
      'end_timestamp': event.endTime.millisecondsSinceEpoch ~/ 1000,
      if (event.description != null) 'description': event.description,
    };
  }

  /// Get all events (optionally filtered by date range)
  /// GET /calendar/events?start_timestamp=X&end_timestamp=Y&max_results=Z
  Future<List<CalendarEvent>> getEvents({
    DateTime? startDate,
    DateTime? endDate,
    int? maxResults,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (startDate != null) {
        queryParams['start_timestamp'] =
            (startDate.millisecondsSinceEpoch ~/ 1000).toString();
      }
      if (endDate != null) {
        queryParams['end_timestamp'] =
            (endDate.millisecondsSinceEpoch ~/ 1000).toString();
      }
      if (maxResults != null) {
        queryParams['max_results'] = maxResults.toString();
      }

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final events = (data['events'] as List)
            .map((json) => _mapResponseToEvent(json))
            .toList();
        return events;
      } else {
        print('Get events error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Get events error: $e');
      return [];
    }
  }

  /// Get event by ID
  /// GET /calendar/events/{id}
  Future<CalendarEvent?> getEventById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _mapResponseToEvent(data);
      } else {
        print('Get event error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Get event error: $e');
      return null;
    }
  }

  /// Create new event
  /// POST /calendar/events
  Future<CalendarEvent?> createEvent({
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
    String? color,
  }) async {
    try {
      final event = CalendarEvent(
        id: '', // Will be set by backend
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        color: color ?? '#C98938',
      );

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode(_mapEventToRequest(event)),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final createdEvent = _mapResponseToEvent(data);
        // Preserve frontend color
        return createdEvent.copyWith(color: color ?? '#C98938');
      } else {
        print('Create event error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Create event error: $e');
      return null;
    }
  }

  /// Update existing event
  /// PUT /calendar/events/{id}
  Future<CalendarEvent?> updateEvent(
    String id, {
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? color,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (title != null) {
        updateData['summary'] = title;
      }
      if (description != null) {
        updateData['description'] = description;
      }
      if (startTime != null) {
        updateData['start_timestamp'] = startTime.millisecondsSinceEpoch ~/ 1000;
      }
      if (endTime != null) {
        updateData['end_timestamp'] = endTime.millisecondsSinceEpoch ~/ 1000;
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: _headers,
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedEvent = _mapResponseToEvent(data);
        // Preserve frontend color if provided
        return color != null ? updatedEvent.copyWith(color: color) : updatedEvent;
      } else {
        print('Update event error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Update event error: $e');
      return null;
    }
  }

  /// Delete event
  /// DELETE /calendar/events/{id}
  Future<bool> deleteEvent(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('Delete event error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Delete event error: $e');
      return false;
    }
  }

  /// Helper: Get events for a specific date
  Future<List<CalendarEvent>> getEventsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return getEvents(startDate: startOfDay, endDate: endOfDay);
  }

  /// Helper: Get events for a specific month
  Future<List<CalendarEvent>> getEventsForMonth(int year, int month) async {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    return getEvents(startDate: startOfMonth, endDate: endOfMonth);
  }
}

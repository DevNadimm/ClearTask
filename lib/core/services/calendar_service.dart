import 'package:clear_task/core/services/auth_service.dart';
import 'package:clear_task/data/datasources/db_helper.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;

class CalendarService {
  final AuthService _authService;
  final DBHelper _dbHelper = DBHelper();

  CalendarService(this._authService);

  /// Create a Google Calendar event for a task.
  /// Returns the event ID or null if failed.
  Future<String?> createEvent({
    required int localTaskId,
    required String title,
    required String date,
    String? time,
  }) async {
    try {
      final calendarApi = await _getCalendarApi();
      if (calendarApi == null) return null;

      final event = gcal.Event(
        summary: '📋 $title',
        description: 'Created by ClearTask',
        start: _buildEventDateTime(date, time),
        end: _buildEventDateTime(date, time, addHours: 1),
      );

      final created = await calendarApi.events.insert(event, 'primary');
      final eventId = created.id;
      debugPrint('📅 Calendar event created: $eventId');

      if (eventId != null) {
        await _dbHelper.setCalendarEventId(localTaskId, eventId);
      }
      return eventId;
    } catch (e) {
      debugPrint('❌ Calendar create failed: $e');
      return null;
    }
  }

  /// Update an existing Google Calendar event.
  Future<void> updateEvent({
    required String eventId,
    required String title,
    required String date,
    String? time,
  }) async {
    try {
      final calendarApi = await _getCalendarApi();
      if (calendarApi == null) return;

      final event = gcal.Event(
        summary: '📋 $title',
        description: 'Created by ClearTask',
        start: _buildEventDateTime(date, time),
        end: _buildEventDateTime(date, time, addHours: 1),
      );

      await calendarApi.events.update(event, 'primary', eventId);
      debugPrint('📅 Calendar event updated: $eventId');
    } catch (e) {
      debugPrint('❌ Calendar update failed: $e');
    }
  }

  /// Delete a Google Calendar event.
  Future<void> deleteEvent(String eventId) async {
    try {
      final calendarApi = await _getCalendarApi();
      if (calendarApi == null) return;

      await calendarApi.events.delete('primary', eventId);
      debugPrint('📅 Calendar event deleted: $eventId');
    } catch (e) {
      debugPrint('❌ Calendar delete failed: $e');
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  Future<gcal.CalendarApi?> _getCalendarApi() async {
    final httpClient =
        await _authService.googleSignIn.authenticatedClient();
    if (httpClient == null) {
      debugPrint('⚠️ No authenticated client for Calendar API');
      return null;
    }
    return gcal.CalendarApi(httpClient);
  }

  gcal.EventDateTime _buildEventDateTime(
    String date,
    String? time, {
    int addHours = 0,
  }) {
    // date format: yyyy-MM-dd
    if (time != null && time.isNotEmpty) {
      final dt = DateTime.parse('$date $time').add(Duration(hours: addHours));
      return gcal.EventDateTime(dateTime: dt, timeZone: 'UTC');
    } else {
      // All-day event
      final dt = DateTime.parse(date).add(Duration(hours: addHours));
      return gcal.EventDateTime(date: dt);
    }
  }
}

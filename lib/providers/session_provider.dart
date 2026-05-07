// lib/providers/session_provider.dart
// Provider for managing Study Session state

import 'package:flutter/material.dart';
import '../models/study_session_model.dart';
import '../services/hive_service.dart';

class SessionProvider extends ChangeNotifier {
  final HiveService _hiveService = HiveService();

  List<StudySessionModel> _sessions = [];

  List<StudySessionModel> get sessions => _sessions;

  List<StudySessionModel> get upcomingSessions =>
      _hiveService.getUpcomingSessions();

  // ─── Load Data ───────────────────────────────────────────────────────────────

  void loadData() {
    _sessions = _hiveService.getAllSessions();
    notifyListeners();
  }

  // ─── Session Operations ──────────────────────────────────────────────────────

  Future<void> addSession({
    required String subjectId,
    required String topicId,
    required DateTime scheduledDate,
    required int durationMinutes,
    String notes = '',
  }) async {
    final session = StudySessionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subjectId: subjectId,
      topicId: topicId,
      scheduledDate: scheduledDate,
      durationMinutes: durationMinutes,
      notes: notes,
      createdAt: DateTime.now(),
    );
    await _hiveService.addSession(session);
    loadData();
  }

  Future<void> deleteSession(String id) async {
    await _hiveService.deleteSession(id);
    loadData();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  /// Get sessions for a specific date
  List<StudySessionModel> getSessionsForDate(DateTime date) {
    return _sessions.where((s) {
      return s.scheduledDate.year == date.year &&
          s.scheduledDate.month == date.month &&
          s.scheduledDate.day == date.day;
    }).toList();
  }

  /// Total sessions count
  int get totalSessions => _sessions.length;
}

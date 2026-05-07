// lib/providers/subject_provider.dart
// Provider for managing Subject & Topic state

import 'package:flutter/material.dart';
import '../models/subject_model.dart';
import '../models/topic_model.dart';
import '../services/hive_service.dart';

class SubjectProvider extends ChangeNotifier {
  final HiveService _hiveService = HiveService();

  List<SubjectModel> _subjects = [];
  List<TopicModel> _topics = [];

  List<SubjectModel> get subjects => _subjects;
  List<TopicModel> get topics => _topics;

  // Color options for subjects
  static const List<int> subjectColors = [
    0xFF6200EE, // Purple
    0xFF03DAC6, // Teal
    0xFFFF5722, // Deep Orange
    0xFF2196F3, // Blue
    0xFF4CAF50, // Green
    0xFFF44336, // Red
    0xFFFF9800, // Orange
    0xFF9C27B0, // Deep Purple
  ];

  // ─── Load Data ───────────────────────────────────────────────────────────────

  void loadData() {
    _subjects = _hiveService.getAllSubjects();
    _topics = _hiveService.getAllTopics();
    notifyListeners();
  }

  // ─── Subject Operations ──────────────────────────────────────────────────────

  Future<void> addSubject(String name, int colorIndex) async {
    final subject = SubjectModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      colorHex: subjectColors[colorIndex % subjectColors.length].toString(),
      createdAt: DateTime.now(),
    );
    await _hiveService.addSubject(subject);
    loadData();
  }

  Future<void> deleteSubject(String id) async {
    await _hiveService.deleteSubject(id);
    loadData();
  }

  // ─── Topic Operations ────────────────────────────────────────────────────────

  Future<void> addTopic(
      String subjectId, String name, int estimatedMinutes) async {
    final topic = TopicModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subjectId: subjectId,
      name: name,
      estimatedMinutes: estimatedMinutes,
      status: TopicStatus.notStarted,
      createdAt: DateTime.now(),
    );
    await _hiveService.addTopic(topic);
    loadData();
  }

  Future<void> updateTopicStatus(String topicId, String newStatus) async {
    final topic = _hiveService.getTopicById(topicId);
    if (topic != null) {
      topic.status = newStatus;
      await _hiveService.updateTopic(topic);
      loadData();
    }
  }

  Future<void> deleteTopic(String topicId) async {
    await _hiveService.deleteTopic(topicId);
    loadData();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  List<TopicModel> getTopicsForSubject(String subjectId) {
    return _topics.where((t) => t.subjectId == subjectId).toList();
  }

  SubjectModel? getSubjectById(String id) {
    try {
      return _subjects.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns completion percentage (0.0 to 1.0) for a subject
  double getSubjectCompletionPercent(String subjectId) {
    final subjectTopics = getTopicsForSubject(subjectId);
    if (subjectTopics.isEmpty) return 0.0;
    final completed =
        subjectTopics.where((t) => t.status == TopicStatus.completed).length;
    return completed / subjectTopics.length;
  }

  /// Total topics count
  int get totalTopics => _topics.length;

  /// Completed topics count
  int get completedTopics =>
      _topics.where((t) => t.status == TopicStatus.completed).length;

  /// Pending (not started) topics count
  int get pendingTopics =>
      _topics.where((t) => t.status == TopicStatus.notStarted).length;

  /// In-progress topics count
  int get inProgressTopics =>
      _topics.where((t) => t.status == TopicStatus.inProgress).length;

  /// Subject with lowest completion (for priority suggestion)
  SubjectModel? get lowestCompletionSubject {
    if (_subjects.isEmpty) return null;
    SubjectModel? lowest;
    double lowestPercent = 2.0;
    for (final subject in _subjects) {
      final percent = getSubjectCompletionPercent(subject.id);
      if (percent < lowestPercent) {
        lowestPercent = percent;
        lowest = subject;
      }
    }
    return lowest;
  }

  /// Next topic to study (first not-started topic of lowest subject)
  TopicModel? get suggestedNextTopic {
    final subject = lowestCompletionSubject;
    if (subject == null) return null;
    final subjectTopics = getTopicsForSubject(subject.id);
    try {
      return subjectTopics
          .firstWhere((t) => t.status == TopicStatus.notStarted);
    } catch (_) {
      try {
        return subjectTopics
            .firstWhere((t) => t.status == TopicStatus.inProgress);
      } catch (_) {
        return null;
      }
    }
  }
}

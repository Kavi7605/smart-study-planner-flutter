// lib/services/hive_service.dart
// Centralized service for all Hive database operations

import 'package:hive_flutter/hive_flutter.dart';
import '../models/subject_model.dart';
import '../models/topic_model.dart';
import '../models/study_session_model.dart';

class HiveService {
  // Box names as constants
  static const String subjectBoxName = 'subjects';
  static const String topicBoxName = 'topics';
  static const String sessionBoxName = 'sessions';

  // Getter for open boxes
  Box<SubjectModel> get subjectBox => Hive.box<SubjectModel>(subjectBoxName);
  Box<TopicModel> get topicBox => Hive.box<TopicModel>(topicBoxName);
  Box<StudySessionModel> get sessionBox =>
      Hive.box<StudySessionModel>(sessionBoxName);

  // ─── Initialize Hive ────────────────────────────────────────────────────────

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(SubjectModelAdapter());
    Hive.registerAdapter(TopicModelAdapter());
    Hive.registerAdapter(StudySessionModelAdapter());

    // Open boxes
    await Hive.openBox<SubjectModel>(subjectBoxName);
    await Hive.openBox<TopicModel>(topicBoxName);
    await Hive.openBox<StudySessionModel>(sessionBoxName);
  }

  // ─── SUBJECT CRUD ────────────────────────────────────────────────────────────

  Future<void> addSubject(SubjectModel subject) async {
    await subjectBox.put(subject.id, subject);
  }

  Future<void> updateSubject(SubjectModel subject) async {
    await subjectBox.put(subject.id, subject);
  }

  Future<void> deleteSubject(String id) async {
    await subjectBox.delete(id);
    // Also delete all topics of this subject
    final topicsToDelete = topicBox.values
        .where((t) => t.subjectId == id)
        .map((t) => t.id)
        .toList();
    for (final topicId in topicsToDelete) {
      await topicBox.delete(topicId);
    }
    // Also delete sessions
    final sessionsToDelete = sessionBox.values
        .where((s) => s.subjectId == id)
        .map((s) => s.id)
        .toList();
    for (final sessionId in sessionsToDelete) {
      await sessionBox.delete(sessionId);
    }
  }

  List<SubjectModel> getAllSubjects() {
    return subjectBox.values.toList();
  }

  SubjectModel? getSubjectById(String id) {
    return subjectBox.get(id);
  }

  // ─── TOPIC CRUD ──────────────────────────────────────────────────────────────

  Future<void> addTopic(TopicModel topic) async {
    await topicBox.put(topic.id, topic);
  }

  Future<void> updateTopic(TopicModel topic) async {
    await topicBox.put(topic.id, topic);
  }

  Future<void> deleteTopic(String id) async {
    await topicBox.delete(id);
  }

  List<TopicModel> getAllTopics() {
    return topicBox.values.toList();
  }

  List<TopicModel> getTopicsForSubject(String subjectId) {
    return topicBox.values
        .where((t) => t.subjectId == subjectId)
        .toList();
  }

  TopicModel? getTopicById(String id) {
    return topicBox.get(id);
  }

  // ─── STUDY SESSION CRUD ──────────────────────────────────────────────────────

  Future<void> addSession(StudySessionModel session) async {
    await sessionBox.put(session.id, session);
  }

  Future<void> updateSession(StudySessionModel session) async {
    await sessionBox.put(session.id, session);
  }

  Future<void> deleteSession(String id) async {
    await sessionBox.delete(id);
  }

  List<StudySessionModel> getAllSessions() {
    final sessions = sessionBox.values.toList();
    sessions.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return sessions;
  }

  List<StudySessionModel> getUpcomingSessions() {
    final now = DateTime.now();
    return sessionBox.values
        .where((s) => s.scheduledDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }
}

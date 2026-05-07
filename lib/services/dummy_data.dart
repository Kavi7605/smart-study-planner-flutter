// lib/services/dummy_data.dart
// Seeds sample data on first app launch

import '../models/subject_model.dart';
import '../models/topic_model.dart';
import '../models/study_session_model.dart';
import 'hive_service.dart';

class DummyData {
  static Future<void> seed(HiveService hiveService) async {
    // Only seed if no data exists
    if (hiveService.subjectBox.isNotEmpty) return;

    final now = DateTime.now();

    // ── Subjects ──────────────────────────────────────────────────────────────
    final subjects = [
      SubjectModel(
        id: '1001',
        name: 'Mathematics',
        colorHex: '0xFF5C6BC0',
        createdAt: now,
      ),
      SubjectModel(
        id: '1002',
        name: 'Physics',
        colorHex: '0xFF26A69A',
        createdAt: now,
      ),
      SubjectModel(
        id: '1003',
        name: 'Computer Science',
        colorHex: '0xFFEF5350',
        createdAt: now,
      ),
      SubjectModel(
        id: '1004',
        name: 'English',
        colorHex: '0xFFFF7043',
        createdAt: now,
      ),
    ];

    for (final s in subjects) {
      await hiveService.addSubject(s);
    }

    // ── Topics for Mathematics ────────────────────────────────────────────────
    final mathTopics = [
      TopicModel(
          id: '2001',
          subjectId: '1001',
          name: 'Algebra Basics',
          estimatedMinutes: 60,
          status: TopicStatus.completed,
          createdAt: now),
      TopicModel(
          id: '2002',
          subjectId: '1001',
          name: 'Quadratic Equations',
          estimatedMinutes: 90,
          status: TopicStatus.completed,
          createdAt: now),
      TopicModel(
          id: '2003',
          subjectId: '1001',
          name: 'Trigonometry',
          estimatedMinutes: 120,
          status: TopicStatus.inProgress,
          createdAt: now),
      TopicModel(
          id: '2004',
          subjectId: '1001',
          name: 'Calculus',
          estimatedMinutes: 150,
          status: TopicStatus.notStarted,
          createdAt: now),
    ];

    // ── Topics for Physics ────────────────────────────────────────────────────
    final physicsTopics = [
      TopicModel(
          id: '2005',
          subjectId: '1002',
          name: 'Motion & Laws',
          estimatedMinutes: 90,
          status: TopicStatus.completed,
          createdAt: now),
      TopicModel(
          id: '2006',
          subjectId: '1002',
          name: 'Thermodynamics',
          estimatedMinutes: 120,
          status: TopicStatus.inProgress,
          createdAt: now),
      TopicModel(
          id: '2007',
          subjectId: '1002',
          name: 'Electrostatics',
          estimatedMinutes: 100,
          status: TopicStatus.notStarted,
          createdAt: now),
      TopicModel(
          id: '2008',
          subjectId: '1002',
          name: 'Optics',
          estimatedMinutes: 80,
          status: TopicStatus.notStarted,
          createdAt: now),
    ];

    // ── Topics for Computer Science ───────────────────────────────────────────
    final csTopics = [
      TopicModel(
          id: '2009',
          subjectId: '1003',
          name: 'Data Structures',
          estimatedMinutes: 180,
          status: TopicStatus.completed,
          createdAt: now),
      TopicModel(
          id: '2010',
          subjectId: '1003',
          name: 'Algorithms',
          estimatedMinutes: 150,
          status: TopicStatus.completed,
          createdAt: now),
      TopicModel(
          id: '2011',
          subjectId: '1003',
          name: 'Database Management',
          estimatedMinutes: 120,
          status: TopicStatus.completed,
          createdAt: now),
      TopicModel(
          id: '2012',
          subjectId: '1003',
          name: 'Operating Systems',
          estimatedMinutes: 100,
          status: TopicStatus.inProgress,
          createdAt: now),
    ];

    // ── Topics for English ────────────────────────────────────────────────────
    final englishTopics = [
      TopicModel(
          id: '2013',
          subjectId: '1004',
          name: 'Grammar Rules',
          estimatedMinutes: 60,
          status: TopicStatus.notStarted,
          createdAt: now),
      TopicModel(
          id: '2014',
          subjectId: '1004',
          name: 'Essay Writing',
          estimatedMinutes: 90,
          status: TopicStatus.notStarted,
          createdAt: now),
      TopicModel(
          id: '2015',
          subjectId: '1004',
          name: 'Reading Comprehension',
          estimatedMinutes: 75,
          status: TopicStatus.notStarted,
          createdAt: now),
    ];

    final allTopics = [
      ...mathTopics,
      ...physicsTopics,
      ...csTopics,
      ...englishTopics
    ];
    for (final t in allTopics) {
      await hiveService.addTopic(t);
    }

    // ── Sample Sessions ───────────────────────────────────────────────────────
    final sessions = [
      StudySessionModel(
        id: '3001',
        subjectId: '1001',
        topicId: '2003',
        scheduledDate: now.add(const Duration(days: 1, hours: 2)),
        durationMinutes: 90,
        notes: 'Focus on sin/cos identities',
        createdAt: now,
      ),
      StudySessionModel(
        id: '3002',
        subjectId: '1002',
        topicId: '2006',
        scheduledDate: now.add(const Duration(days: 2, hours: 3)),
        durationMinutes: 60,
        notes: 'Review 1st and 2nd law',
        createdAt: now,
      ),
      StudySessionModel(
        id: '3003',
        subjectId: '1004',
        topicId: '2013',
        scheduledDate: now.add(const Duration(days: 3, hours: 4)),
        durationMinutes: 45,
        notes: '',
        createdAt: now,
      ),
    ];

    for (final s in sessions) {
      await hiveService.addSession(s);
    }
  }
}

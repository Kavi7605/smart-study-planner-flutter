// lib/models/topic_model.dart
// Hive model for Topic

import 'package:hive/hive.dart';

part 'topic_model.g.dart';

// Status constants for topic completion
class TopicStatus {
  static const String notStarted = 'Not Started';
  static const String inProgress = 'In Progress';
  static const String completed = 'Completed';
}

@HiveType(typeId: 1)
class TopicModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String subjectId; // foreign key to SubjectModel

  @HiveField(2)
  late String name;

  @HiveField(3)
  late int estimatedMinutes; // estimated study time in minutes

  @HiveField(4)
  late String status; // TopicStatus constant

  @HiveField(5)
  late DateTime createdAt;

  TopicModel({
    required this.id,
    required this.subjectId,
    required this.name,
    required this.estimatedMinutes,
    required this.status,
    required this.createdAt,
  });
}

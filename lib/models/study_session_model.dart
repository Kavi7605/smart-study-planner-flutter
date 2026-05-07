// lib/models/study_session_model.dart
// Hive model for Study Session

import 'package:hive/hive.dart';

part 'study_session_model.g.dart';

@HiveType(typeId: 2)
class StudySessionModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String subjectId;

  @HiveField(2)
  late String topicId;

  @HiveField(3)
  late DateTime scheduledDate; // date + time combined

  @HiveField(4)
  late int durationMinutes; // planned session duration

  @HiveField(5)
  late String notes; // optional notes

  @HiveField(6)
  late DateTime createdAt;

  StudySessionModel({
    required this.id,
    required this.subjectId,
    required this.topicId,
    required this.scheduledDate,
    required this.durationMinutes,
    required this.notes,
    required this.createdAt,
  });
}

// lib/models/subject_model.dart
// Hive model for Subject

import 'package:hive/hive.dart';

part 'subject_model.g.dart';

@HiveType(typeId: 0)
class SubjectModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String colorHex; // e.g. "0xFF6200EE"

  @HiveField(3)
  late DateTime createdAt;

  SubjectModel({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.createdAt,
  });
}

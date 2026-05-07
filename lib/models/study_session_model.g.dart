// lib/models/study_session_model.g.dart
// GENERATED CODE - Manually written to avoid build_runner requirement

part of 'study_session_model.dart';

class StudySessionModelAdapter extends TypeAdapter<StudySessionModel> {
  @override
  final int typeId = 2;

  @override
  StudySessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudySessionModel(
      id: fields[0] as String,
      subjectId: fields[1] as String,
      topicId: fields[2] as String,
      scheduledDate: fields[3] as DateTime,
      durationMinutes: fields[4] as int,
      notes: fields[5] as String,
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, StudySessionModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subjectId)
      ..writeByte(2)
      ..write(obj.topicId)
      ..writeByte(3)
      ..write(obj.scheduledDate)
      ..writeByte(4)
      ..write(obj.durationMinutes)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudySessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

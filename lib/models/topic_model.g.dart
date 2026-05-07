// lib/models/topic_model.g.dart
// GENERATED CODE - Manually written to avoid build_runner requirement

part of 'topic_model.dart';

class TopicModelAdapter extends TypeAdapter<TopicModel> {
  @override
  final int typeId = 1;

  @override
  TopicModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TopicModel(
      id: fields[0] as String,
      subjectId: fields[1] as String,
      name: fields[2] as String,
      estimatedMinutes: fields[3] as int,
      status: fields[4] as String,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TopicModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subjectId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.estimatedMinutes)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopicModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

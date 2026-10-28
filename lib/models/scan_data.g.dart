// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScanDataAdapter extends TypeAdapter<ScanData> {
  @override
  final int typeId = 0;

  @override
  ScanData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanData(
      imagePath: fields[0] as String,
      condition: fields[1] as String,
      confidence: fields[2] as int,
      date: fields[3] as DateTime,
      userId: fields[4] as String,
      isDeleted: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ScanData obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.imagePath)
      ..writeByte(1)
      ..write(obj.condition)
      ..writeByte(2)
      ..write(obj.confidence)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.userId)
      ..writeByte(5)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

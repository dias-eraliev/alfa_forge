// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuoteAdapter extends TypeAdapter<Quote> {
  @override
  final int typeId = 10;

  @override
  Quote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Quote(
      id: fields[0] as String,
      text: fields[1] as String,
      author: fields[2] as String,
      category: fields[3] as QuoteCategory,
      timeContext: fields[4] as TimeContext,
      priority: fields[5] as int,
      tags: (fields[6] as List).cast<String>(),
      targetZones: (fields[7] as List).cast<String>(),
      isPremium: fields[8] as bool,
      lastShown: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Quote obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.timeContext)
      ..writeByte(5)
      ..write(obj.priority)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.targetZones)
      ..writeByte(8)
      ..write(obj.isPremium)
      ..writeByte(9)
      ..write(obj.lastShown);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationSettingsAdapter extends TypeAdapter<NotificationSettings> {
  @override
  final int typeId = 11;

  @override
  NotificationSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationSettings(
      isEnabled: fields[0] as bool,
      startHour: fields[1] as int,
      endHour: fields[2] as int,
      intervalMinutes: fields[3] as int,
      enabledCategories: (fields[4] as List).cast<String>(),
      soundEnabled: fields[5] as bool,
      vibrationEnabled: fields[6] as bool,
      weekendsEnabled: fields[7] as bool,
      disabledDays: (fields[8] as List).cast<int>(),
      preferredTimeZone: fields[9] as String,
      smartScheduling: fields[10] as bool,
      premiumQuotesEnabled: fields[11] as bool,
      maxDailyQuotes: fields[12] as int,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationSettings obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.isEnabled)
      ..writeByte(1)
      ..write(obj.startHour)
      ..writeByte(2)
      ..write(obj.endHour)
      ..writeByte(3)
      ..write(obj.intervalMinutes)
      ..writeByte(4)
      ..write(obj.enabledCategories)
      ..writeByte(5)
      ..write(obj.soundEnabled)
      ..writeByte(6)
      ..write(obj.vibrationEnabled)
      ..writeByte(7)
      ..write(obj.weekendsEnabled)
      ..writeByte(8)
      ..write(obj.disabledDays)
      ..writeByte(9)
      ..write(obj.preferredTimeZone)
      ..writeByte(10)
      ..write(obj.smartScheduling)
      ..writeByte(11)
      ..write(obj.premiumQuotesEnabled)
      ..writeByte(12)
      ..write(obj.maxDailyQuotes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

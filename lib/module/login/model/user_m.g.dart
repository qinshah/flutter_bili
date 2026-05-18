// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_m.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserMAdapter extends TypeAdapter<UserM> {
  @override
  final typeId = 0;

  @override
  UserM read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserM(
      accessKey: fields[0] as String,
      refreshToken: fields[1] as String,
      sessdata: fields[2] as String,
      csrf: fields[3] as String,
      expiresAt: fields[4] as DateTime,
      cookies: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserM obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.accessKey)
      ..writeByte(1)
      ..write(obj.refreshToken)
      ..writeByte(2)
      ..write(obj.sessdata)
      ..writeByte(3)
      ..write(obj.csrf)
      ..writeByte(4)
      ..write(obj.expiresAt)
      ..writeByte(5)
      ..write(obj.cookies);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

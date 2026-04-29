// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential_m.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CredentialsAdapter extends TypeAdapter<CredentialM> {
  @override
  final typeId = 0;

  @override
  CredentialM read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CredentialM(
      accessKey: fields[0] as String,
      refreshToken: fields[1] as String,
      sessdata: fields[2] as String,
      csrf: fields[3] as String,
      expiresAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CredentialM obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.accessKey)
      ..writeByte(1)
      ..write(obj.refreshToken)
      ..writeByte(2)
      ..write(obj.sessdata)
      ..writeByte(3)
      ..write(obj.csrf)
      ..writeByte(4)
      ..write(obj.expiresAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CredentialsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

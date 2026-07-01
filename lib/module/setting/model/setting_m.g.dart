// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_m.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerKernelAdapter extends TypeAdapter<PlayerKernel> {
  @override
  final typeId = 2;

  @override
  PlayerKernel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PlayerKernel.mpv;
      case 1:
        return PlayerKernel.mdk;
      default:
        return PlayerKernel.mpv;
    }
  }

  @override
  void write(BinaryWriter writer, PlayerKernel obj) {
    switch (obj) {
      case PlayerKernel.mpv:
        writer.writeByte(0);
      case PlayerKernel.mdk:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerKernelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

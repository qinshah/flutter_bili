// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_m.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingMAdapter extends TypeAdapter<SettingM> {
  @override
  final typeId = 1;

  @override
  SettingM read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingM(
      playerLibrary: fields[0] == null
          ? PlayerLibraryM.mediaKit
          : fields[0] as PlayerLibraryM,
      enableDanmaku: fields[1] == null ? true : fields[1] as bool,
      videoQuality: fields[2] == null
          ? VideoQualityM.a1080p30
          : fields[2] as VideoQualityM,
      autoPlay: fields[3] == null ? false : fields[3] as bool,
      muteByDefault: fields[4] == null ? false : fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SettingM obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.playerLibrary)
      ..writeByte(1)
      ..write(obj.enableDanmaku)
      ..writeByte(2)
      ..write(obj.videoQuality)
      ..writeByte(3)
      ..write(obj.autoPlay)
      ..writeByte(4)
      ..write(obj.muteByDefault);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingMAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlayerLibraryMAdapter extends TypeAdapter<PlayerLibraryM> {
  @override
  final typeId = 2;

  @override
  PlayerLibraryM read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PlayerLibraryM.mediaKit;
      case 1:
        return PlayerLibraryM.fvp;
      default:
        return PlayerLibraryM.mediaKit;
    }
  }

  @override
  void write(BinaryWriter writer, PlayerLibraryM obj) {
    switch (obj) {
      case PlayerLibraryM.mediaKit:
        writer.writeByte(0);
      case PlayerLibraryM.fvp:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerLibraryMAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VideoQualityMAdapter extends TypeAdapter<VideoQualityM> {
  @override
  final typeId = 3;

  @override
  VideoQualityM read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return VideoQualityM.a360p;
      case 1:
        return VideoQualityM.a480p;
      case 2:
        return VideoQualityM.a720p;
      case 3:
        return VideoQualityM.a1080p30;
      case 4:
        return VideoQualityM.a1080p60;
      case 5:
        return VideoQualityM.a4k30;
      case 6:
        return VideoQualityM.a4k60;
      case 7:
        return VideoQualityM.a8k30;
      case 8:
        return VideoQualityM.a8k60;
      default:
        return VideoQualityM.a360p;
    }
  }

  @override
  void write(BinaryWriter writer, VideoQualityM obj) {
    switch (obj) {
      case VideoQualityM.a360p:
        writer.writeByte(0);
      case VideoQualityM.a480p:
        writer.writeByte(1);
      case VideoQualityM.a720p:
        writer.writeByte(2);
      case VideoQualityM.a1080p30:
        writer.writeByte(3);
      case VideoQualityM.a1080p60:
        writer.writeByte(4);
      case VideoQualityM.a4k30:
        writer.writeByte(5);
      case VideoQualityM.a4k60:
        writer.writeByte(6);
      case VideoQualityM.a8k30:
        writer.writeByte(7);
      case VideoQualityM.a8k60:
        writer.writeByte(8);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoQualityMAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

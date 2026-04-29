// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_m.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<SettingsM> {
  @override
  final typeId = 1;

  @override
  SettingsM read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsM(
      playerLibrary: fields[0] == null
          ? PlayerLibrary.mediaKit
          : fields[0] as PlayerLibrary,
      enableDanmaku: fields[1] == null ? true : fields[1] as bool,
      videoQuality: fields[2] == null
          ? VideoQuality.a1080p30
          : fields[2] as VideoQuality,
      autoPlay: fields[3] == null ? false : fields[3] as bool,
      muteByDefault: fields[4] == null ? false : fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsM obj) {
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
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlayerLibraryAdapter extends TypeAdapter<PlayerLibrary> {
  @override
  final typeId = 2;

  @override
  PlayerLibrary read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PlayerLibrary.mediaKit;
      case 1:
        return PlayerLibrary.fvp;
      default:
        return PlayerLibrary.mediaKit;
    }
  }

  @override
  void write(BinaryWriter writer, PlayerLibrary obj) {
    switch (obj) {
      case PlayerLibrary.mediaKit:
        writer.writeByte(0);
      case PlayerLibrary.fvp:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerLibraryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VideoQualityAdapter extends TypeAdapter<VideoQuality> {
  @override
  final typeId = 3;

  @override
  VideoQuality read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return VideoQuality.a360p;
      case 1:
        return VideoQuality.a480p;
      case 2:
        return VideoQuality.a720p;
      case 3:
        return VideoQuality.a1080p30;
      case 4:
        return VideoQuality.a1080p60;
      case 5:
        return VideoQuality.a4k30;
      case 6:
        return VideoQuality.a4k60;
      case 7:
        return VideoQuality.a8k30;
      case 8:
        return VideoQuality.a8k60;
      default:
        return VideoQuality.a360p;
    }
  }

  @override
  void write(BinaryWriter writer, VideoQuality obj) {
    switch (obj) {
      case VideoQuality.a360p:
        writer.writeByte(0);
      case VideoQuality.a480p:
        writer.writeByte(1);
      case VideoQuality.a720p:
        writer.writeByte(2);
      case VideoQuality.a1080p30:
        writer.writeByte(3);
      case VideoQuality.a1080p60:
        writer.writeByte(4);
      case VideoQuality.a4k30:
        writer.writeByte(5);
      case VideoQuality.a4k60:
        writer.writeByte(6);
      case VideoQuality.a8k30:
        writer.writeByte(7);
      case VideoQuality.a8k60:
        writer.writeByte(8);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoQualityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

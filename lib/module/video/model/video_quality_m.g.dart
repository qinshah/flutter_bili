// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_quality_m.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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

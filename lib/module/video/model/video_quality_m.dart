import 'package:json_annotation/json_annotation.dart';

enum VideoQualityM {
  @JsonValue('8K60')
  a8k60('8K60', 60, 188),
  @JsonValue('8K30')
  a8k30('8K30', 30, 156),
  @JsonValue('4K60')
  a4k60('4K60', 60, 132),
  @JsonValue('4K30')
  a4k30('4K30', 30, 120),
  @JsonValue('1080P60')
  a1080p60('1080P60', 60, 112),
  @JsonValue('1080P30')
  a1080p30('1080P30', 30, 80),
  @JsonValue('720P')
  a720p('720P', 30, 64),
  @JsonValue('480P')
  a480p('480P', 30, 32),
  @JsonValue('360P')
  a360p('360P', 30, 16);

  final String name;
  final int fps;
  final int qn;

  const VideoQualityM(this.name, this.fps, this.qn);
}

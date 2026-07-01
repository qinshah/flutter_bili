import 'package:hive_ce/hive_ce.dart';

part 'video_quality_m.g.dart';

@HiveType(typeId: 3)
enum VideoQualityM {
  @HiveField(8)
  a8k60('8K60', 60, 188),
  @HiveField(7)
  a8k30('8K30', 30, 156),
  @HiveField(6)
  a4k60('4K60', 60, 132),
  @HiveField(5)
  a4k30('4K30', 30, 120),
  @HiveField(4)
  a1080p60('1080P60', 60, 112),
  @HiveField(3)
  a1080p30('1080P30', 30, 80),
  @HiveField(2)
  a720p('720P', 30, 64),
  @HiveField(1)
  a480p('480P', 30, 32),
  @HiveField(0)
  a360p('360P', 30, 16);

  final String name;
  final int fps;
  final int qn;

  const VideoQualityM(this.name, this.fps, this.qn);
}

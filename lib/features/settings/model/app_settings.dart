import 'package:hive_ce/hive_ce.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 2)
enum PlayerLibrary {
  @HiveField(0)
  mediaKit,
  @HiveField(1)
  fvp,
}

@HiveType(typeId: 3)
enum VideoQuality {
  @HiveField(8)
  a8k60('8K60', 60),
  @HiveField(7)
  a8k30('8K30', 30),
  @HiveField(6)
  a4k60('4K60', 60),
  @HiveField(5)
  a4k30('4K30', 30),
  @HiveField(4)
  a1080p60('1080P60', 60),
  @HiveField(3)
  a1080p30('1080P30', 30),
  @HiveField(2)
  a720p('720P', 30),
  @HiveField(1)
  a480p('480P', 30),
  @HiveField(0)
  a360p('360P', 30);

  final String name;
  final int fps;

  const VideoQuality(this.name, this.fps);
}

@HiveType(typeId: 1)
class AppSettings {
  @HiveField(0)
  PlayerLibrary playerLibrary;

  @HiveField(1)
  bool enableDanmaku;

  @HiveField(2)
  VideoQuality videoQuality;

  @HiveField(3)
  bool autoPlay;

  @HiveField(4)
  bool muteByDefault;

  /// 默认设置
  AppSettings({
    this.playerLibrary = PlayerLibrary.mediaKit,
    this.enableDanmaku = true,
    this.videoQuality = VideoQuality.a1080p30,
    this.autoPlay = false,
    this.muteByDefault = false,
  });

  AppSettings copyWith({
    PlayerLibrary? playerLibrary,
    bool? enableDanmaku,
    VideoQuality? videoQuality,
    bool? autoPlay,
    bool? muteByDefault,
  }) {
    return AppSettings(
      playerLibrary: playerLibrary ?? this.playerLibrary,
      enableDanmaku: enableDanmaku ?? this.enableDanmaku,
      videoQuality: videoQuality ?? this.videoQuality,
      autoPlay: autoPlay ?? this.autoPlay,
      muteByDefault: muteByDefault ?? this.muteByDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerLibrary': playerLibrary.name,
      'enableDanmaku': enableDanmaku,
      'videoQuality': videoQuality.name,
      'autoPlay': autoPlay,
      'muteByDefault': muteByDefault,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      playerLibrary: PlayerLibrary.values.firstWhere(
        (e) => e.name == json['playerLibrary'],
        orElse: () => PlayerLibrary.mediaKit,
      ),
      enableDanmaku: json['enableDanmaku'] ?? true,
      videoQuality: VideoQuality.values.firstWhere(
        (e) => e.name == json['videoQuality'],
        orElse: () => VideoQuality.a1080p30,
      ),
      autoPlay: json['autoPlay'] ?? false,
      muteByDefault: json['muteByDefault'] ?? false,
    );
  }
}

import 'package:hive_ce/hive_ce.dart';

part 'setting_m.g.dart';

@HiveType(typeId: 2)
enum PlayerLibraryM {
  @HiveField(0)
  mediaKit,
  @HiveField(1)
  fvp,
}

@HiveType(typeId: 3)
enum VideoQualityM {
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

  const VideoQualityM(this.name, this.fps);
}

@HiveType(typeId: 1)
class SettingM {
  @HiveField(0)
  PlayerLibraryM playerLibrary;

  @HiveField(1)
  bool enableDanmaku;

  @HiveField(2)
  VideoQualityM videoQuality;

  @HiveField(3)
  bool autoPlay;

  @HiveField(4)
  bool muteByDefault;

  /// 默认设置
  SettingM({
    this.playerLibrary = PlayerLibraryM.mediaKit,
    this.enableDanmaku = true,
    this.videoQuality = VideoQualityM.a1080p30,
    this.autoPlay = false,
    this.muteByDefault = false,
  });

  SettingM copyWith({
    PlayerLibraryM? playerLibrary,
    bool? enableDanmaku,
    VideoQualityM? videoQuality,
    bool? autoPlay,
    bool? muteByDefault,
  }) {
    return SettingM(
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

  factory SettingM.fromJson(Map<String, dynamic> json) {
    return SettingM(
      playerLibrary: PlayerLibraryM.values.firstWhere(
        (e) => e.name == json['playerLibrary'],
        orElse: () => PlayerLibraryM.mediaKit,
      ),
      enableDanmaku: json['enableDanmaku'] ?? true,
      videoQuality: VideoQualityM.values.firstWhere(
        (e) => e.name == json['videoQuality'],
        orElse: () => VideoQualityM.a1080p30,
      ),
      autoPlay: json['autoPlay'] ?? false,
      muteByDefault: json['muteByDefault'] ?? false,
    );
  }
}

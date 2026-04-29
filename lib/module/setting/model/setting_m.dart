import 'package:flutter_bili/module/video/model/video_quality_m.dart';
import 'package:hive_ce/hive_ce.dart';

part 'setting_m.g.dart';

@HiveType(typeId: 2)
enum PlayerLibraryM {
  @HiveField(0)
  mediaKit,
  @HiveField(1)
  fvp,
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

// ignore_for_file: unnecessary_this

import 'package:flutter_bili/module/video/model/video_quality_m.dart';
import 'package:json_annotation/json_annotation.dart';

part 'setting_m.g.dart';

enum PlayerKernel {
  mpv,
  mdk,
}

@JsonSerializable()
class SettingM {
  @JsonKey(name: 'playerKernel')
  PlayerKernel playerKernel;

  bool enableDanmaku;

  VideoQualityM videoQuality;

  bool autoPlay;

  bool muteByDefault;

  /// 默认设置
  SettingM({
    this.playerKernel = PlayerKernel.mpv,
    this.enableDanmaku = true,
    this.videoQuality = VideoQualityM.a1080p30,
    this.autoPlay = false,
    this.muteByDefault = false,
  });

  SettingM copyWith({
    PlayerKernel? playerKernel,
    bool? enableDanmaku,
    VideoQualityM? videoQuality,
    bool? autoPlay,
    bool? muteByDefault,
  }) {
    return SettingM(
      playerKernel: playerKernel ?? this.playerKernel,
      enableDanmaku: enableDanmaku ?? this.enableDanmaku,
      videoQuality: videoQuality ?? this.videoQuality,
      autoPlay: autoPlay ?? this.autoPlay,
      muteByDefault: muteByDefault ?? this.muteByDefault,
    );
  }

  factory SettingM.fromJson(Map<String, dynamic> json) =>
      _$SettingMFromJson(json);

  Map<String, dynamic> toJson() => _$SettingMToJson(this);
}

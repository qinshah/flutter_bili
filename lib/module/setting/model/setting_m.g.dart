// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_m.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingM _$SettingMFromJson(Map<String, dynamic> json) => SettingM(
  playerKernel:
      $enumDecodeNullable(_$PlayerKernelEnumMap, json['playerKernel']) ??
      PlayerKernel.mpv,
  enableDanmaku: json['enableDanmaku'] as bool? ?? true,
  videoQuality:
      $enumDecodeNullable(_$VideoQualityMEnumMap, json['videoQuality']) ??
      VideoQualityM.a1080p30,
  autoPlay: json['autoPlay'] as bool? ?? false,
  muteByDefault: json['muteByDefault'] as bool? ?? false,
);

Map<String, dynamic> _$SettingMToJson(SettingM instance) => <String, dynamic>{
  'playerKernel': _$PlayerKernelEnumMap[instance.playerKernel]!,
  'enableDanmaku': instance.enableDanmaku,
  'videoQuality': _$VideoQualityMEnumMap[instance.videoQuality]!,
  'autoPlay': instance.autoPlay,
  'muteByDefault': instance.muteByDefault,
};

const _$PlayerKernelEnumMap = {
  PlayerKernel.mpv: 'mpv',
  PlayerKernel.mdk: 'mdk',
};

const _$VideoQualityMEnumMap = {
  VideoQualityM.a8k60: '8K60',
  VideoQualityM.a8k30: '8K30',
  VideoQualityM.a4k60: '4K60',
  VideoQualityM.a4k30: '4K30',
  VideoQualityM.a1080p60: '1080P60',
  VideoQualityM.a1080p30: '1080P30',
  VideoQualityM.a720p: '720P',
  VideoQualityM.a480p: '480P',
  VideoQualityM.a360p: '360P',
};

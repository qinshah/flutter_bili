export 'package:flutter_bili/module/setting/model/setting_m.dart';
export 'package:flutter_bili/module/video/model/video_quality_m.dart';

import 'package:flutter_bili/module/setting/model/setting_m.dart';
import 'package:flutter_bili/module/video/model/video_quality_m.dart';
import 'package:flutter_bili/service/storage_s.dart';

enum SettingCategory {
  defaults('默认'),
  player('播放器'),
  appearance('外观');

  final String title;
  const SettingCategory(this.title);
}

enum SettingEnum {
  playerKernel('播放器内核', category: SettingCategory.player),
  enableDanmaku('弹幕', category: SettingCategory.player),
  videoQuality('画质', category: SettingCategory.player),
  autoPlay('自动播放', category: SettingCategory.player),
  muteByDefault('默认静音', category: SettingCategory.player);

  final String title;
  final SettingCategory category;
  const SettingEnum(this.title, {this.category = SettingCategory.defaults});
}

class Setting<T, D> {
  static final _box = StorageS.settingsB;
  final SettingEnum item;
  final T defaultValue;
  final D Function(T value)? enCoder;
  final T Function(D data)? deCoder;

  Setting._(
    this.item, {
    required this.defaultValue,
    this.enCoder,
    this.deCoder,
  }) {
    values.add(this);
  }

  Future<void> delete() => _box.delete(item.name);

  T? maybeGet() {
    final data = _box.get(item.name);
    if (data == null) return null;
    return deCoder == null ? data : deCoder!(data);
  }

  T get() => maybeGet() ?? defaultValue;

  Future<void> set(T value) =>
      _box.put(item.name, enCoder?.call(value) ?? value);

  static final values = <Setting>{};

  static final playerKernel = Setting<PlayerKernel, String>._(
    SettingEnum.playerKernel,
    defaultValue: PlayerKernel.mpv,
    enCoder: (value) => value.name,
    deCoder: (data) => PlayerKernel.values.byName(data),
  );
  static final enableDanmaku = Setting<bool, bool>._(
    SettingEnum.enableDanmaku,
    defaultValue: true,
  );
  static final videoQuality = Setting<VideoQualityM, String>._(
    SettingEnum.videoQuality,
    defaultValue: VideoQualityM.a1080p30,
    enCoder: (value) => value.name,
    deCoder: (data) => VideoQualityM.values.byName(data),
  );
  static final autoPlay = Setting<bool, bool>._(
    SettingEnum.autoPlay,
    defaultValue: true,
  );
}

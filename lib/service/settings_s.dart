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

class Setting<T> {
  static final _box = StorageS.settingsB;
  final SettingEnum item;
  final T defaultValue;

  Setting._(this.item, {required this.defaultValue}) {
    values.add(this);
  }

  Future<void> delete() => _box.delete(item.name);

  T? maybeGet() => _box.get(item.name);

  T get() => maybeGet() ?? defaultValue;

  Future<void> set(T value) => _box.put(item.name, value);

  static final values = <Setting>{};

  static final playerKernel = Setting<PlayerKernel>._(
    SettingEnum.playerKernel,
    defaultValue: PlayerKernel.mpv,
  );
  static final enableDanmaku = Setting<bool>._(
    SettingEnum.enableDanmaku,
    defaultValue: true,
  );
  static final videoQuality = Setting<VideoQualityM>._(
    SettingEnum.videoQuality,
    defaultValue: VideoQualityM.a1080p30,
  );
  static final autoPlay = Setting<bool>._(
    SettingEnum.autoPlay,
    defaultValue: true,
  );
}

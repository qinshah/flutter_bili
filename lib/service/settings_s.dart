// import 'dart:convert';

// import 'package:flutter_bili/model/serializable/serializable.dart';
// import 'package:flutter_bili/module/setting/model/setting_m.dart';
// import 'package:flutter_bili/module/video/model/video_quality_m.dart';
// import 'package:flutter_bili/service/storage_s.dart';

// enum SettingCategory {
//   player('播放器'),
//   appearance('外观');

//   final String title;
//   const SettingCategory(this.title);
// }

// class Setting<T extends Serializable> {
//   static final _box = StorageS.settingB;
//   final String key;
//   final String title;
//   final SettingCategory category;
//   final T Function(Map<String, dynamic> json) fromJson;
//   Setting._({
//     required this.key,
//     required this.title,
//     required this.category,
//     required this.fromJson,
//   }) {
//     values.add(this);
//   }

//   Future<void> delete() => _box.delete(key);

//   T? get() {
//     final json = _box.get(key);
//     if (json == null) return null;
//     return fromJson(jsonDecode(json));
//   }

//   Future<void> set(T value) async {
//     await _box.put(key, jsonEncode(value.toJson()));
//   }

//   static final values = <Setting>[];

//   static final playerKernel = Setting<PlayerKernel>._(
//     key: 'playerKernel',
//     title: '播放器内核',
//     category: SettingCategory.player,
//   );
//   static final enableDanmaku = Setting<SerializableBool>._(
//     key: 'enableDanmaku',
//     title: '弹幕',
//     category: SettingCategory.player,
//     fromJson: (json) => SerializableBool.fromJson(json),
//   );
//   static final videoQuality = Setting<VideoQualityM>._(
//     key: 'videoQuality',
//     title: '画质',
//     category: SettingCategory.player,
//   );
//   static final autoPlay = Setting<bool>._(
//     key: 'autoPlay',
//     title: '自动播放',
//     category: SettingCategory.player,
//   );
// }

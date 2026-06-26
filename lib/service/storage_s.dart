import 'dart:convert';

import 'package:flutter_bili/hive_registrar.g.dart';
import 'package:flutter_bili/module/login/model/user_m.dart';
import 'package:flutter_bili/module/setting/model/setting_m.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

abstract final class StorageS {
  static late final Box<UserM> userB;
  static late final Box<dynamic> cacheB;
  static late final Box<String> mainB;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapters();
    userB = await Hive.openBox<UserM>('UserM');
    cacheB = await Hive.openBox<dynamic>('CacheM');
    mainB = await Hive.openBox<String>('SettingM');
  }

  Future<Box<T>> openBox<T>() async {
    return Hive.openBox<T>(T.runtimeType.toString());
  }

  static SettingM getSetting() {
    final saved = mainB.get('settings');
    if (saved == null) {
      print('bili: 本地设置为空');
      return SettingM();
    }
    try {
      return SettingM.fromJson(jsonDecode(saved));
    } catch (e) {
      print('bili: 解析设置失败: $e');
      return SettingM();
    }
  }

  static Future<void> saveSettings(SettingM appSettings) async {
    try {
      await mainB.put('settings', jsonEncode(appSettings.toJson()));
    } catch (e) {
      print('bili: 保存设置失败: $e');
    }
  }
}

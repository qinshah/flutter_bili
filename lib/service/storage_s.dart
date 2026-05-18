import 'package:flutter_bili/hive_registrar.g.dart';
import 'package:flutter_bili/module/login/model/user_m.dart';
import 'package:flutter_bili/module/setting/model/setting_m.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

abstract final class StorageS {
  static late final Box<UserM> userB;
  static late final Box<dynamic> cacheB;
  static late final Box<SettingM> settingsB;
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapters();
    userB = await Hive.openBox<UserM>('UserM');
    cacheB = await Hive.openBox<dynamic>('CacheM');
    settingsB = await Hive.openBox<SettingM>('SettingsM');
  }

  Future<Box<T>> openBox<T>() async {
    return Hive.openBox<T>(T.runtimeType.toString());
  }

  static SettingM getSetting() {
    final saved = settingsB.get('main');
    if (saved == null) {
      print('bili: 本地设置为空');
      return SettingM();
    }
    return saved;
  }

  static Future<void> saveSettings(SettingM appSettings) async {
    try {
      await settingsB.put('main', appSettings);
    } catch (e) {
      print('bili: 保存设置失败: $e');
    }
  }
}

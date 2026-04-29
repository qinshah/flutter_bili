import 'package:flutter_bili/feature/login/model/credential_m.dart';
import 'package:flutter_bili/feature/setting/model/setting_m.dart';
import 'package:flutter_bili/hive_registrar.g.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

abstract final class StorageS {
  static late final Box<CredentialM> credentialB;
  static late final Box<dynamic> cacheB;
  static late final Box<SettingM> settingsB;
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapters();
    credentialB = await Hive.openBox<CredentialM>('CredentialM');
    cacheB = await Hive.openBox<dynamic>('CacheM');
    settingsB = await Hive.openBox<SettingM>('SettingsM');
  }

  Future<Box<T>> openBox<T>() async {
    return Hive.openBox<T>(T.runtimeType.toString());
  }

  static SettingM getLocal() {
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

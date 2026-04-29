import 'package:flutter_bili/features/login/model/credentials.dart';
import 'package:flutter_bili/features/settings/model/app_settings.dart';
import 'package:flutter_bili/hive_registrar.g.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

abstract final class StorageService {
  static late Box<Credentials> credentials;
  static late Box<dynamic> cache;
  static late Box<AppSettings> _settings;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapters();
    credentials = await Hive.openBox<Credentials>('credentials');
    cache = await Hive.openBox<dynamic>('cache');
    _settings = await Hive.openBox<AppSettings>('settings');
  }

  static AppSettings getLocal() {
    final saved = _settings.get('main');
    if (saved == null) {
      print('bili: 本地设置为空');
      return AppSettings();
    }
    return saved;
  }

  static Future<void> saveSettings(AppSettings appSettings) async {
    try {
      await _settings.put('main', appSettings);
    } catch (e) {
      print('bili: 保存设置失败: $e');
    }
  }
}

import 'dart:convert';

import 'package:flutter_bili/hive_registrar.g.dart';
import 'package:flutter_bili/module/login/model/user_m.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

abstract final class StorageS {
  static late final Box<UserM> userB;
  static late final Box<dynamic> cacheB;
  static late final Box<dynamic> settingsB;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapters();
    userB = await Hive.openBox<UserM>('UserM');
    cacheB = await Hive.openBox<dynamic>('CacheM');
    settingsB = await Hive.openBox<dynamic>('SettingsB');
  }

  static String exportSettings() {
    return JsonEncoder.withIndent('  ').convert(settingsB.toMap());
  }

  static Future<void> importSettings(String data) async {
    await settingsB.clear();
    await settingsB.addAll(jsonDecode(data));
  }

  static Future<void> resetSettings() async => await settingsB.clear();
}

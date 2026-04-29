import 'package:hive_ce_flutter/hive_flutter.dart';
import '../../login/model/credentials.dart';

abstract final class StorageService {
  static late Box<Credentials> credentials;
  static late Box<dynamic> cache;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CredentialsAdapter());
    credentials = await Hive.openBox<Credentials>('credentials');
    cache = await Hive.openBox<dynamic>('cache');
  }
}

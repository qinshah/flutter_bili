import 'package:flutter/foundation.dart';
import '../core/app_storage.dart';
import '../models/auth/credentials.dart';

class AuthService extends ChangeNotifier {
  Credentials? _credentials;

  bool get isLogin => _credentials != null;
  String? get accessKey => _credentials?.accessKey;
  String? get sessdata => _credentials?.sessdata;
  String? get csrf => _credentials?.csrf;
  Credentials? get credentials => _credentials;

  /// Load credentials from Hive storage on app startup
  void loadFromStorage() {
    _credentials = AppStorage.credentials.get('main');
    notifyListeners();
  }

  /// Save credentials to Hive and update state
  Future<void> saveCredentials({
    required String accessKey,
    required String refreshToken,
    required String sessdata,
    required String csrf,
    DateTime? expiresAt,
  }) async {
    final cred = Credentials(
      accessKey: accessKey,
      refreshToken: refreshToken,
      sessdata: sessdata,
      csrf: csrf,
      expiresAt: expiresAt ?? DateTime.now().add(const Duration(days: 30)),
    );
    await AppStorage.credentials.put('main', cred);
    _credentials = cred;
    notifyListeners();
  }

  /// Clear credentials from storage and update state
  Future<void> clearCredentials() async {
    await AppStorage.credentials.delete('main');
    _credentials = null;
    notifyListeners();
  }
}

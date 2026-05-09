import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../module/login/model/credential_m.dart';
import 'storage_s.dart';

class AuthS extends ChangeNotifier {
  AuthS._();
  static final AuthS i = AuthS._();
  late final Box<CredentialM> _credentialBox = StorageS.credentialB;

  CredentialM? _credentials;

  bool get isLogin => _credentials != null;
  String? get accessKey => _credentials?.accessKey;
  String? get sessdata => _credentials?.sessdata;
  String? get csrf => _credentials?.csrf;
  CredentialM? get credentials => _credentials;

  /// Load credentials from local storage
  void loadLocalCredential() {
    _credentials = _credentialBox.get('main');
    print('加载登录信息: $_credentials');
    notifyListeners();
  }

  /// Save credentials to Hive and update state
  Future<void> saveCredentials({
    required String accessKey,
    required String refreshToken,
    required String sessdata,
    required String csrf,
    DateTime? expiresAt,
    String? cookies,
  }) async {
    final cred = CredentialM(
      accessKey: accessKey,
      refreshToken: refreshToken,
      sessdata: sessdata,
      csrf: csrf,
      expiresAt: expiresAt ?? DateTime.now().add(const Duration(days: 30)),
    );
    await _credentialBox.put('main', cred);
    if (cookies != null && cookies.isNotEmpty) {
      await StorageS.cacheB.put('loginCookies', cookies);
    }
    _credentials = cred;
    print('保存登录信息: $_credentials');
    notifyListeners();
  }

  /// Clear credentials from storage and update state
  Future<void> clearCredentials() async {
    print('清理登录信息');
    // TODO: fixing
    // await _credentialBox.delete('main');
    // await StorageS.cacheB.delete('loginCookies');
    _credentials = null;
    notifyListeners();
  }
}

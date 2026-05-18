import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../module/login/model/user_m.dart';
import 'storage_s.dart';

class AuthS extends ChangeNotifier {
  AuthS._();
  static final AuthS i = AuthS._();
  late final Box<UserM> _userBox = StorageS.userB;

  UserM? _curUser;

  bool get isLogin => _curUser != null;
  UserM? get curUser => _curUser;
  String? get accessKey => _curUser?.accessKey;
  String? get sessdata => _curUser?.sessdata;
  String? get csrf => _curUser?.csrf;
  String? get cookies => _curUser?.cookies;

  List<UserM> get users => _userBox.values.toList();

  /// Load credentials from local storage
  void loadLocalUsers() {
    final all = users;
    if (all.isNotEmpty) {
      _curUser = all.last;
    }
    notifyListeners();
  }

  Future<void> saveUser({
    required String accessKey,
    required String refreshToken,
    required String sessdata,
    required String csrf,
    DateTime? expiresAt,
    String? cookies,
  }) async {
    final user = UserM(
      accessKey: accessKey,
      refreshToken: refreshToken,
      sessdata: sessdata,
      csrf: csrf,
      expiresAt: expiresAt ?? DateTime.now().add(const Duration(days: 30)),
      cookies: cookies ?? '',
    );
    await _userBox.add(user);
    _curUser = user;
    notifyListeners();
  }

  void switchUser(UserM? user) {
    _curUser = user;
    notifyListeners();
  }

  Future<void> logout() async {
    _curUser = null;
    notifyListeners();
  }
}

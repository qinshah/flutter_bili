import 'package:dio/dio.dart';
import 'package:flutter_bili/module/login/model/credential_m.dart';
import 'package:flutter_bili/service/storage_s.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Business codes that indicate the session is no longer valid.
const _authFailureCodes = {-101, -102, -111, -400};

/// URL fragments that identify App-side (TV/passport) endpoints.
/// These receive `access_key` in query parameters.
const _appSidePathFragments = [
  '/passport-tv-login',
  '/x/passport-login',
];

class AuthInterceptor extends Interceptor {
  final Box<CredentialM> _credentialB = StorageS.credentialB;
  final Box<dynamic> _cacheB = StorageS.cacheB;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final cred = _credentialB.get('main');

    if (cred != null) {
      final isAppSide = _appSidePathFragments.any(
        (fragment) => options.path.contains(fragment),
      );

      if (isAppSide) {
        // App-side: inject access_key into query parameters
        options.queryParameters['access_key'] = cred.accessKey;
      } else {
        // Web-side: inject full cookies into Cookie header
        final fullCookies = _cacheB.get('loginCookies') as String?;
        if (fullCookies != null && fullCookies.isNotEmpty) {
          options.headers['Cookie'] = fullCookies;
        } else {
          // Fallback: only inject SESSDATA
          final existing = options.headers['Cookie'] as String? ?? '';
          final sessdata = 'SESSDATA=${cred.sessdata}';
          options.headers['Cookie'] = existing.isEmpty
              ? sessdata
              : '$existing; $sessdata';
        }
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onResponse(
    // 父类写死
    // ignore: strict_raw_type
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final data = response.data;
    if (data is Map) {
      final code = data['code'];
      if (code is int && _authFailureCodes.contains(code)) {
        await _clearAndRedirect();
      }
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _clearAndRedirect();
    }
    handler.next(err);
  }

  Future<void> _clearAndRedirect() async {
    await _credentialB.delete('main');
    // 不自动跳转登录页，让用户手动点击登录按钮
    // 这样避免强制跳转且无法关闭的问题
  }
}

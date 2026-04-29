import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../service/storage_service.dart';

/// Global navigator key — register this in MaterialApp.navigatorKey
/// so AuthInterceptor can navigate without a BuildContext.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Business codes that indicate the session is no longer valid.
const _authFailureCodes = {-101, -102, -111, -400};

/// URL fragments that identify App-side (TV/passport) endpoints.
/// These receive `access_key` in query parameters.
const _appSidePathFragments = [
  '/passport-tv-login',
  '/x/passport-login',
];

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) {
    final cred = StorageService.credentials.get('main');

    if (cred != null) {
      final isAppSide = _appSidePathFragments
          .any((fragment) => options.path.contains(fragment));

      if (isAppSide) {
        // App-side: inject access_key into query parameters
        options.queryParameters['access_key'] = cred.accessKey;
      } else {
        // Web-side: inject SESSDATA into Cookie header
        final existing = options.headers['Cookie'] as String? ?? '';
        final sessdata = 'SESSDATA=${cred.sessdata}';
        options.headers['Cookie'] =
            existing.isEmpty ? sessdata : '$existing; $sessdata';
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;
    if (data is Map) {
      final code = data['code'];
      if (code is int && _authFailureCodes.contains(code)) {
        _clearAndRedirect();
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _clearAndRedirect();
    }
    handler.next(err);
  }

  void _clearAndRedirect() {
    StorageService.credentials.delete('main');
    // 不自动跳转登录页，让用户手动点击登录按钮
    // 这样避免强制跳转且无法关闭的问题
  }
}

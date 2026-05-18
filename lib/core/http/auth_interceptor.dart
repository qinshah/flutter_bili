import 'package:dio/dio.dart';

import '../../service/auth_s.dart';

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
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final cred = AuthS.i.curUser;

    if (cred != null) {
      final isAppSide = _appSidePathFragments.any(
        (fragment) => options.path.contains(fragment),
      );

      if (isAppSide) {
        // App-side: inject access_key into query parameters
        options.queryParameters['access_key'] = cred.accessKey;
      } else {
        // Web-side: inject full cookies into Cookie header
        final fullCookies = cred.cookies;
        if (fullCookies.isNotEmpty) {
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
}

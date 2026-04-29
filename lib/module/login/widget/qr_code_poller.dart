import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/http/login_http.dart';
import '../../../service/auth_s.dart';

class QrCodePoller {
  final AuthS authService;
  final VoidCallback onExpired;
  final void Function(String error) onError;
  final VoidCallback onSuccess;

  Timer? _timer;
  bool _running = false;

  QrCodePoller({
    required this.authService,
    required this.onExpired,
    required this.onError,
    required this.onSuccess,
  });

  void start(String authCode) {
    stop();
    _running = true;
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!_running) return;
      try {
        final result = await LoginHttp.codePoll(authCode);
        final code = result['code'] as int;
        if (code == 0) {
          stop();
          final data = result['data'] as Map<String, dynamic>;
          try {
            await authService.saveCredentials(
              accessKey: data['access_token'] as String? ?? '',
              refreshToken: data['refresh_token'] as String? ?? '',
              sessdata: _extractSessdata(data),
              csrf: _extractCsrf(data),
            );
            print('保存登录数据成功');
          } catch (e) {
            print('保存登录数据失败: $e');
          }
          onSuccess();
        } else if (code == 86038) {
          stop();
          onExpired();
        }
        // code == 86090 means waiting for scan, continue polling
      } catch (e) {
        stop();
        onError(e.toString());
      }
    });
  }

  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => stop();

  String _extractSessdata(Map<String, dynamic> data) {
    final cookies = data['cookie_info']?['cookies'] as List?;
    if (cookies != null) {
      for (final c in cookies) {
        if (c['name'] == 'SESSDATA') return c['value'] as String? ?? '';
      }
    }
    return '';
  }

  String _extractCsrf(Map<String, dynamic> data) {
    final cookies = data['cookie_info']?['cookies'] as List?;
    if (cookies != null) {
      for (final c in cookies) {
        if (c['name'] == 'bili_jct') return c['value'] as String? ?? '';
      }
    }
    return '';
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_bili/app/http/api.dart';
import 'package:flutter_bili/app/http/loading_state.dart';
import 'package:flutter_bili/app/http/request.dart';
import 'package:flutter_bili/app/utils/app_sign.dart';

abstract final class LoginHttp {
  /// POST /x/passport-tv-login/qrcode/auth_code (AppSign)
  static Future<LoadingState<({String authCode, String url})>>
  getAuthCode() async {
    try {
      final params = <String, dynamic>{
        'local_id': '0',
        'platform': 'android',
        'mobi_app': 'android_hd',
      };
      AppSign.appSign(params);
      final res = await Request().post(
        Api.getTVCode,
        queryParameters: params,
      );
      if (res.data['code'] == 0) {
        try {
          final Map<String, dynamic> data = res.data['data'];
          return Success((authCode: data['auth_code'] as String, url: data['url'] as String));
        } catch (e) {
          return Error('解析响应失败: $e');
        }
      } else {
        return Error(res.data['message'] as String? ?? '获取二维码失败');
      }
    } on DioException catch (e) {
      return Error('网络请求失败: ${e.message}');
    } catch (e) {
      return Error('未知错误: $e');
    }
  }

  /// POST /x/passport-tv-login/qrcode/poll (AppSign)
  static Future<Map<String, dynamic>> codePoll(String authCode) async {
    try {
      final params = <String, dynamic>{
        'auth_code': authCode,
        'local_id': '0',
      };
      AppSign.appSign(params);
      final res = await Request().post(
        Api.qrcodePoll,
        queryParameters: params,
      );
      return {
        'status': res.data['code'] == 0,
        'code': res.data['code'],
        'data': res.data['data'],
        'msg': res.data['message'],
      };
    } catch (e) {
      return {
        'status': false,
        'code': -1,
        'data': null,
        'msg': '网络请求失败: $e',
      };
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_bili/core/http/api.dart';
import 'package:flutter_bili/core/utils/app_sign.dart';

import '../../module/up/model/space_archive.dart';
import '../../module/up/model/space_data.dart';
import '../utils/wbi_sign.dart';
import 'loading_state.dart';
import 'request.dart';

abstract final class MemberHttp {
  /// 获取UP主卡片信息（无需wbi签名）
  /// https://api.bilibili.com/x/web-interface/card?mid=xxx&photo=true
  static Future<LoadingState<SpaceCard>> userCard({required int mid}) async {
    final res = await Request().get(
      '/x/web-interface/card',
      queryParameters: {
        'mid': mid,
        'photo': true,
      },
    );

    if (res.data['code'] == 0) {
      final card = res.data['data']?['card'] as Map<String, dynamic>?;
      if (card == null) {
        return Error('用户不存在');
      }
      return Success(SpaceCard.fromJson(card));
    } else {
      return Error(res.data['message']?.toString());
    }
  }

  /// 获取UP主投稿视频列表（Web端，需要wbi签名）
  /// https://api.bilibili.com/x/space/wbi/arc/search
  static Future<LoadingState<SpaceArchiveData>> spaceSearch({
    required int mid,
    String order = 'pubdate',
    int pn = 1,
    int ps = 30,
  }) async {
    final params = await WbiSign.makSign({
      'mid': mid,
      'order': order,
      'pn': pn,
      'ps': ps,
      'tid': 0,
    });

    final res = await Request().get(
      '/x/space/wbi/arc/search',
      queryParameters: params,
    );

    print('获取UP主投稿视频列表: ${res.data}');

    if (res.data['code'] == 0) {
      return Success(
        SpaceArchiveData.fromJson(
          res.data['data'] as Map<String, dynamic>,
        ),
      );
    } else {
      return Error(res.data['message']?.toString());
    }
  }

  /// 获取UP主投稿视频列表
  static Future<LoadingState<SpaceArchiveData>> spaceArchive({
    required int mid,
    String? aid,
    String? order,
    int? next,
  }) async {
    final params = <String, Object>{
      'aid': ?aid,
      'build': 8430300,
      'version': '8.43.0',
      'c_locale': 'zh_CN',
      'channel': 'master',
      'mobi_app': 'android',
      'platform': 'android',
      's_locale': 'zh_CN',
      'ps': 20, // 每页条数
      'next': ?next,
      'qn': 80, // 80代表视频
      'order': ?order,
      'vmid': mid,
    };
    AppSign.appSign(params);
    final res = await Request().get(
      Api.spaceArchive,
      queryParameters: params,
      options: Options(
        headers: {
          'bili-http-engine': 'cronet',
          'user-agent':
              'Mozilla/5.0 BiliDroid/8.43.0 (bbcallen@gmail.com) os/android model/android mobi_app/android build/8430300 channel/master innerVer/8430300 osVer/15 network/2',
        },
      ),
    );

    if (res.data['code'] == 0) {
      return Success(
        SpaceArchiveData.fromJson(
          res.data['data'] as Map<String, dynamic>,
        ),
      );
    } else {
      return Error(res.data['message']?.toString());
    }
  }
}

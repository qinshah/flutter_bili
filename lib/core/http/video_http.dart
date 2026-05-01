import '../../module/video/model/play_url_model.dart';
import '../../module/video/model/related_video.dart';
import '../../module/video/model/video_detail.dart';
import '../../service/auth_s.dart';
import '../utils/wbi_sign.dart';
import 'api.dart';
import 'loading_state.dart';
import 'request.dart';

abstract final class VideoHttp {
  /// 获取视频详情
  static Future<LoadingState<VideoDetailData>> videoDetail({
    required String bvid,
  }) async {
    final res = await Request().get(
      Api.videoIntro,
      queryParameters: {'bvid': bvid},
    );

    if (res.data['code'] == 0) {
      return Success(VideoDetailData.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }

  /// 获取视频播放URL
  static Future<LoadingState<PlayUrlModel>> videoUrl({
    required String bvid,
    required int cid,
    int? qn,
  }) async {
    final params = <String, Object>{
      'bvid': bvid,
      'cid': cid,
      'qn': qn ?? 80,
      'fnval': 4048,
      'fourk': 1,
      'fnver': 0,
      'voice_balance': 1,
      'web_location': 1315873,
      'gaia_source': 'pre-load',
    };

    // 未登录时开启免登录试看(最高1080P)
    if (!AuthS.i.isLogin) {
      params['try_look'] = 1;
    }

    final signedParams = await WbiSign.makSign(params);

    final res = await Request().get(
      Api.ugcUrl,
      queryParameters: signedParams,
    );

    if (res.data['code'] == 0) {
      return Success(PlayUrlModel.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }

  /// 获取相关推荐视频
  static Future<LoadingState<List<RelatedVideoItem>>> relatedVideoList({
    required String bvid,
  }) async {
    final res = await Request().get(
      Api.relatedList,
      queryParameters: {'bvid': bvid},
    );

    if (res.data['code'] == 0) {
      final List<RelatedVideoItem> list = [];
      for (final item in res.data['data'] as List) {
        list.add(RelatedVideoItem.fromJson(item));
      }
      return Success(list);
    } else {
      return Error(res.data['message']);
    }
  }

  /// 上报播放心跳
  static Future<void> heartBeat({
    required String bvid,
    required int cid,
    required int progress,
  }) async {
    try {
      await Request().post(
        Api.heartBeat,
        data: {
          'bvid': bvid,
          'cid': cid,
          'played_time': progress,
        },
      );
    } catch (e) {
      // 忽略心跳错误
    }
  }
}

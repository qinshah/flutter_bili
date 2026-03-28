import 'package:dio/dio.dart';
import 'package:flutter_bili/http/api.dart';
import 'package:flutter_bili/http/loading_state.dart';
import 'package:flutter_bili/http/request.dart';
import 'package:flutter_bili/models/video/play_url_model.dart';
import 'package:flutter_bili/models/video/video_detail.dart';
import 'package:flutter_bili/utils/wbi_sign.dart';

abstract final class VideoHttp {
  /// GET /x/web-interface/view?bvid=xxx
  static Future<LoadingState<VideoDetailData>> videoDetail({
    required String bvid,
  }) async {
    try {
      final res = await Request().get(
        Api.videoIntro,
        queryParameters: {'bvid': bvid},
      );
      if (res.data['code'] == 0) {
        return Success(
          VideoDetailData.fromJson(res.data['data'] as Map<String, dynamic>),
        );
      } else {
        return Error(res.data['message'] as String?);
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// GET /x/player/wbi/playurl with Wbi signature, fnval=4048
  static Future<LoadingState<PlayUrlModel>> videoUrl({
    required String bvid,
    required int cid,
    int? qn,
  }) async {
    try {
      final params = <String, Object>{
        'bvid': bvid,
        'cid': cid,
        'fnval': 4048,
        'fnver': 0,
        'fourk': 1,
        if (qn != null) 'qn': qn,
      };
      await WbiSign.makSign(params);
      final res = await Request().get(
        Api.ugcUrl,
        queryParameters: params.map((k, v) => MapEntry(k, v.toString())),
      );
      if (res.data['code'] == 0) {
        return Success(
          PlayUrlModel.fromJson(res.data['data'] as Map<String, dynamic>),
        );
      } else {
        return Error(res.data['message'] as String?);
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// POST /x/click-interface/web/heartbeat — fire-and-forget
  static Future<void> heartBeat({
    required String bvid,
    required int cid,
    required int progress,
  }) async {
    try {
      await Request().post(
        Api.heartBeat,
        data: FormData.fromMap({
          'bvid': bvid,
          'cid': cid,
          'played_time': progress,
        }),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
    } catch (_) {
      // fire-and-forget: ignore errors
    }
  }
}

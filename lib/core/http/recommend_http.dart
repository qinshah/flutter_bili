import 'package:flutter_bili/core/http/api.dart';
import 'package:flutter_bili/core/http/loading_state.dart';
import 'package:flutter_bili/core/http/request.dart';
import 'package:flutter_bili/features/video/model/rec_video_item.dart';

class RecommendHttp {
  static Future<LoadingState<List<RecVideoItem>>> getRecommendList({
    required int freshIdx,
  }) async {
    try {
      final res = await Request().get(
        Api.recommendListWeb,
        queryParameters: {
          'version': 1,
          'feed_version': 'V8',
          'homepage_ver': 1,
          'ps': 20,
          'fresh_idx': freshIdx,
          'brush': freshIdx,
          'fresh_type': 4,
        },
      );

      if (res.data['code'] == 0) {
        final List<RecVideoItem> list = [];
        for (final item in res.data['data']['item']) {
          if (item['goto'] == 'av') {
            list.add(RecVideoItem.fromJson(item));
          }
        }
        return Success(list);
      } else {
        return Error(res.data['message'] ?? '获取推荐视频失败');
      }
    } catch (e) {
      return Error('网络请求失败: $e');
    }
  }
}

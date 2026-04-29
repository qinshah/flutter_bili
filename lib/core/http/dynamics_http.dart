import 'loading_state.dart';
import 'request.dart';
import 'api.dart';
import '../../module/dynamic/model/dynamics_item.dart';

abstract final class DynamicsHttp {
  /// 获取关注动态列表
  static Future<LoadingState<DynamicsResult>> followDynamic({
    String type = 'all',
    String? offset,
  }) async {
    final res = await Request().get(
      Api.followDynamic,
      queryParameters: {
        'type': type,
        'timezone_offset': '-480',
        'offset': offset,
        'features': 'itemOpusStyle',
      },
    );
    
    if (res.data['code'] == 0) {
      return Success(DynamicsResult.fromJson(res.data['data']));
    } else {
      return Error(res.data['message']);
    }
  }
}

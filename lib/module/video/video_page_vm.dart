import 'package:flutter/foundation.dart';

import '../../core/http/loading_state.dart';
import '../../core/http/video_http.dart';
import 'model/play_url_model.dart';
import 'model/video_detail.dart';

class VideoPageVm extends ChangeNotifier {
  final String _bvid;

  String get bvid => _bvid;

  VideoPageVm({required String bvid}) : _bvid = bvid;

  VideoDetailData? _detail;
  PlayUrlModel? _playUrl;
  int _selectedPage = 0;
  int? _currentQn;
  LoadingState? _detailState;
  LoadingState? _playUrlState;

  int? getCid() => _detail?.pages[_selectedPage].cid;

  VideoDetailData? get detail => _detail;
  PlayUrlModel? get playUrl => _playUrl;
  int get selectedPage => _selectedPage;
  int? get currentQn => _currentQn;
  LoadingState? get detailState => _detailState;
  LoadingState? get playUrlState => _playUrlState;

  /// 获取指定 quality code 的画质描述
  String? getQualityDesc(int qn) {
    final formats = _playUrl?.supportFormats;
    if (formats != null) {
      final format = formats.firstWhere(
        (e) => e.quality == qn,
        orElse: () => FormatItem(),
      );
      if (format.newDesc?.isNotEmpty == true) return format.newDesc;
      if (format.displayDesc?.isNotEmpty == true) return format.displayDesc;
    }
    return null;
  }

  Future<void> loadDetail() async {
    _detailState = null;
    notifyListeners();

    final result = await VideoHttp.videoDetail(bvid: bvid);
    _detailState = result;

    if (result is Success<VideoDetailData>) {
      _detail = result.response;
      _selectedPage = 0;
    }

    notifyListeners();
  }

  Future<void> loadPlayUrl( {int? qn}) async {
    _playUrlState = null;
    notifyListeners();

    final cid = getCid();
    if (cid == null) return;

    final result = await VideoHttp.videoUrl(
      bvid: bvid,
      cid: cid,
      qn: qn,
    );
    _playUrlState = result;

    if (result is Success<PlayUrlModel>) {
      _playUrl = result.response;
      _currentQn = _playUrl?.quality;
    }

    notifyListeners();
  }

  Future<void> selectPage(int index) async {
    if (_detail == null || index < 0 || index >= _detail!.pages.length) return;
    _selectedPage = index;
    notifyListeners();
  }
}

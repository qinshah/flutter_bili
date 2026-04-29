import 'package:flutter/foundation.dart';

import '../../core/http/loading_state.dart';
import '../../core/http/video_http.dart';
import 'model/play_url_model.dart';
import 'model/video_detail.dart';

class VideoPageVm extends ChangeNotifier {
  VideoPageVm._();
  static final VideoPageVm i = VideoPageVm._();

  VideoDetailData? _detail;
  PlayUrlModel? _playUrl;
  int _selectedPage = 0;
  LoadingState? _detailState;
  LoadingState? _playUrlState;

  VideoDetailData? get detail => _detail;
  PlayUrlModel? get playUrl => _playUrl;
  int get selectedPage => _selectedPage;
  LoadingState? get detailState => _detailState;
  LoadingState? get playUrlState => _playUrlState;

  Future<void> loadDetail(String bvid) async {
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

  Future<void> loadPlayUrl(String bvid, int cid, {int? qn}) async {
    _playUrlState = null;
    notifyListeners();

    final result = await VideoHttp.videoUrl(bvid: bvid, cid: cid, qn: qn);
    _playUrlState = result;

    if (result is Success<PlayUrlModel>) {
      _playUrl = result.response;
    }

    notifyListeners();
  }

  void selectPage(int index) {
    if (_detail == null || index < 0 || index >= _detail!.pages.length) return;
    _selectedPage = index;
    notifyListeners();

    final page = _detail!.pages[index];
    loadPlayUrl(_detail!.bvid, page.cid);
  }
}

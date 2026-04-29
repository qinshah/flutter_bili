import 'package:flutter/foundation.dart';

import '../http/loading_state.dart';
import '../http/video_http.dart';
import '../../video/model/play_url_model.dart';
import '../../video/model/video_detail.dart';
import '../../video/model/video_quality.dart';

class VideoService extends ChangeNotifier {
  VideoService._();
  static final VideoService i = VideoService._();

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

  int selectBestQuality(List<int> availableQn) {
    if (availableQn.isEmpty) return 80;

    for (final qn in VideoQuality.priorityOrder) {
      if (availableQn.contains(qn)) return qn;
    }

    return availableQn.first;
  }
}

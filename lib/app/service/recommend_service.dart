import 'package:flutter/material.dart';
import '../http/loading_state.dart';
import '../http/recommend_http.dart';
import '../../video/model/rec_video_item.dart';

/// 首页推荐页面模型
/// 管理视频列表数据、加载状态、滚动位置等所有页面状态
class RecommendService extends ChangeNotifier {
  final List<RecVideoItem> _videoList = [];
  bool _loading = false;
  String? _error;
  int _freshIdx = 0;
  
  // 管理滚动控制器
  final ScrollController _scrollController = ScrollController();
  
  // GridView 的 key，用于保持滚动位置
  final GlobalKey _gridKey = GlobalKey();

  List<RecVideoItem> get videoList => _videoList;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasData => _videoList.isNotEmpty;
  ScrollController get scrollController => _scrollController;
  GlobalKey get gridKey => _gridKey;

  RecommendService() {
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 监听滚动，接近底部时自动加载更多
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_loading) {
        loadMore();
      }
    }
  }

  /// 加载推荐视频
  Future<void> loadVideos() async {
    if (_loading) return;

    _loading = true;
    _error = null;
    notifyListeners();

    final result = await RecommendHttp.getRecommendList(freshIdx: _freshIdx);

    switch (result) {
      case Success(:final response):
        _videoList.addAll(response);
        _freshIdx++;
        _loading = false;
        _error = null;
      case Error(:final message):
        _error = message;
        _loading = false;
    }
    notifyListeners();
  }

  /// 刷新（清空并重新加载）
  Future<void> refresh() async {
    _videoList.clear();
    _freshIdx = 0;
    _error = null;
    notifyListeners();
    await loadVideos();
  }

  /// 加载更多
  Future<void> loadMore() async {
    await loadVideos();
  }
}

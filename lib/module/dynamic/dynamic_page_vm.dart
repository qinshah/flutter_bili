import 'package:flutter/material.dart';
import '../../core/http/dynamics_http.dart';
import '../../core/http/loading_state.dart';
import 'model/dynamics_item.dart';

/// 动态页面服务
class DynamicPageVm extends ChangeNotifier {
  DynamicPageVm._();
  static final DynamicPageVm i = DynamicPageVm._();
  
  final List<DynamicsItem> _videoList = [];
  bool _loading = false;
  String? _error;
  String? _offset;
  bool _hasMore = true;

  List<DynamicsItem> get videoList => _videoList;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  bool get hasData => _videoList.isNotEmpty;

  /// 加载动态列表
  Future<void> loadDynamics() async {
    if (_loading || !_hasMore) return;

    _loading = true;
    _error = null;
    notifyListeners();

    final result = await DynamicsHttp.followDynamic(
      type: 'video',
      offset: _offset,
    );

    switch (result) {
      case Success(:final response):
        _videoList.addAll(response.items);
        _offset = response.offset;
        _hasMore = response.hasMore ?? false;
        _loading = false;
        _error = null;
      case Error(:final message):
        _error = message;
        _loading = false;
    }
    notifyListeners();
  }

  /// 刷新
  Future<void> refresh() async {
    _videoList.clear();
    _offset = null;
    _hasMore = true;
    _error = null;
    notifyListeners();
    await loadDynamics();
  }

  /// 加载更多
  Future<void> loadMore() async {
    await loadDynamics();
  }
}

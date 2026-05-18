import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bili/core/http/loading_state.dart';
import 'package:flutter_bili/core/http/video_http.dart';
import 'package:flutter_bili/infrastructure/media_player/fvp_player.dart';
import 'package:flutter_bili/infrastructure/media_player/media_kit_player.dart';
import 'package:flutter_bili/infrastructure/media_player/media_player.dart';
import 'package:flutter_bili/module/setting/model/setting_m.dart';
import 'package:flutter_bili/service/media_s.dart';
import 'package:flutter_bili/service/storage_s.dart';

import 'model/play_url_model.dart';
import 'model/video_detail.dart';

class VideoPageVm extends ChangeNotifier {
  final String _bvid;

  String get bvid => _bvid;

  VideoPageVm({required String bvid}) : _bvid = bvid;

  MediaPlayer? _player;

  Widget buildVideoView() {
    return _player?.buildVideoView() ?? const SizedBox.shrink();
  }

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
        orElse: FormatItem.new,
      );
      if (format.newDesc?.isNotEmpty ?? false) return format.newDesc;
      if (format.displayDesc?.isNotEmpty ?? false) return format.displayDesc;
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

  Future<void> loadPlayUrl({int? qn}) async {
    _playUrlState = null;
    notifyListeners();

    final cid = getCid();
    if (cid == null) return;

    final result = await VideoHttp.videoUrl(bvid: bvid, cid: cid, qn: qn);
    _playUrlState = result;

    if (result is Success<PlayUrlModel>) {
      _playUrl = result.response;
      _currentQn = _playUrl?.quality;
    }

    notifyListeners();
  }

  void selectPage(int index) {
    if (_detail == null || index < 0 || index >= _detail!.pages.length) return;
    _selectedPage = index;
    notifyListeners();
  }

  // ── Player management ──────────────────────────────────────────────────────

  static const _headers = {
    'referer': 'https://www.bilibili.com',
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
  };

  Future<void> initPlayer({Duration? startPosition}) async {
    final playUrl = _playUrl;
    final cid = getCid();
    if (playUrl == null || cid == null) return;
    await _player?.dispose();
    final setting = StorageS.getSetting();
    try {
      switch (setting.playerLibrary) {
        case PlayerLibraryM.mediaKit:
          _player = await MediaKitPlayer.create(
            playUrl,
            headers: _headers,
            startPosition: startPosition,
          );
        case PlayerLibraryM.fvp:
          _player = await FvpPlayer.create(
            playUrl,
            headers: _headers,
            startPosition: startPosition,
          );
      }
      MediaS.i.player = _player;
      _startHeartbeat(bvid: bvid, cid: cid, player: _player!);
    } on Exception catch (e) {
      debugPrint('VideoPageVm initPlayer failed: $e');
    }
  }

  @override
  Future<void> dispose() async {
    _stopHeartbeat();
    await _player?.dispose();
    super.dispose();
  }

  Future<void> changeQuality(int qn) async {
    final position = MediaS.i.currentPosition;
    await loadPlayUrl(qn: qn);
    if (_playUrl != null) {
      await initPlayer(startPosition: position);
    }
  }

  // ── heartbeat ──────────────────────────────────────────────────────────────
  static Timer _heartbeatTimer = Timer(Duration.zero, () {})..cancel();

  static void _stopHeartbeat() {
    _heartbeatTimer.cancel();
  }

  /// 开始心跳检测，单例
  static void _startHeartbeat({
    required String bvid,
    required int cid,
    required MediaPlayer player,
  }) {
    final playedMilliseconds = player.currentPosition.inMilliseconds;
    _heartbeatTimer.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
      debugPrint('心跳检测模拟: $bvid, $cid, $playedMilliseconds');
      // TODO: 心跳检测网络请求
      // await VideoHttp.heartBeat(
      //   bvid: bvid,
      //   cid: cid,
      //   progress: playedMilliseconds,
      // );
    });
  }

  Future<void> onPushNext(String? next) async {
    print('onPushNext: $next');
    // 跳转到其他页面时暂停播放
    if (next == 'fullscreen') return; // 全屏例外
    _stopHeartbeat();
    await _player?.pause();
  }

  Future<void> onPopNext(String? next) async {
    if (_player == null) return;
    MediaS.i.player = _player;
    await _player!.play();
    int? cid = getCid();
    if (cid == null) return;
    _startHeartbeat(bvid: _bvid, cid: cid, player: _player!);
  }

  Future<void> onPlayOrPause() async {
    MediaS.i.player = _player;
    await MediaS.i.playOrPause();
  }

  bool isVideoLandscape() {
    return (_player?.aspectRatio ?? 2) > 1.3;
  }
}

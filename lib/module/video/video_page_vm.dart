import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bili/core/http/loading_state.dart';
import 'package:flutter_bili/core/http/video_http.dart';
import 'package:flutter_bili/infrastructure/media_player/fvp_player.dart';
import 'package:flutter_bili/infrastructure/media_player/media_kit_player.dart';
import 'package:flutter_bili/infrastructure/media_player/media_player.dart';
import 'package:flutter_bili/module/setting/model/setting_m.dart';
import 'package:flutter_bili/module/video/float_video_v.dart';
import 'package:flutter_bili/module/video/model/playing_info_m.dart';
import 'package:flutter_bili/route/router.dart';
import 'package:flutter_bili/service/media_s.dart';
import 'package:flutter_bili/service/storage_s.dart';
import 'package:flutter_floating/floating/assist/floating_common_params.dart';
import 'package:flutter_floating/floating/floating_overlay.dart';
import 'package:flutter_floating/floating/manager/floating_manager.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:os_type/os_type.dart';
import 'package:screen_brightness/screen_brightness.dart';

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
    if (playUrl == null) return;
    final MediaPlayer newPlayer;
    final setting = StorageS.getSetting();
    try {
      switch (setting.playerLibrary) {
        case PlayerLibraryM.mediaKit:
          newPlayer = await MediaKitPlayer.create(
            playUrl,
            headers: _headers,
            startPosition: startPosition,
          );
        case PlayerLibraryM.fvp:
          newPlayer = await FvpPlayer.create(
            playUrl,
            headers: _headers,
            startPosition: startPosition,
          );
      }
      try {
        // 暂停其他播放器
        await MediaS.i.pause();
      } catch (_) {
        print('TODO 修复MediaS持有的播放器在其它地方被dispose');
      }
      // 暂停其他播放器
      await _player?.dispose(); // 释放可能的旧播放器
      _player = newPlayer;
      await _play();
      notifyListeners();
    } on Exception catch (e) {
      debugPrint('VideoPageVm initPlayer failed: $e');
    }
  }

  final _volumeStreamCntlr = StreamController<double?>.broadcast();
  final _brightnessStreamCntlr = StreamController<double?>.broadcast();

  late StreamSubscription<double> _systemBrightnessSubscription;
  late StreamSubscription<double> _appBrightnessSubscription;

  Stream<double?> get brightnessHubStream => _brightnessStreamCntlr.stream;

  Stream<double?> get volumeHubStream => _volumeStreamCntlr.stream;

  void initUIStream() {
    FlutterVolumeController.addListener((volume) {
      _volumeStreamCntlr.add(volume);
      Future.delayed(const Duration(seconds: 2), () {
        _volumeStreamCntlr.add(null); // 隐藏显示
      });
    });
    void onBrightnessChanged(double brightness) {
      _brightnessStreamCntlr.add(brightness);
      Future.delayed(const Duration(seconds: 2), () {
        _brightnessStreamCntlr.add(null); // 隐藏显示
      });
    }

    _appBrightnessSubscription = ScreenBrightness()
        .onApplicationScreenBrightnessChanged
        .listen(onBrightnessChanged);
    _systemBrightnessSubscription = ScreenBrightness()
        .onSystemScreenBrightnessChanged
        .listen(onBrightnessChanged);
  }

  @override
  Future<void> dispose() async {
    _stopHeartbeat();
    FlutterVolumeController.removeListener();
    _appBrightnessSubscription.cancel();
    _systemBrightnessSubscription.cancel();
    _volumeStreamCntlr.close();
    _brightnessStreamCntlr.close();
    super.dispose();
  }

  Future<void> changeQuality(int qn) async {
    final position = _player?.currentPosition;
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

  // TODO: 转由其它模块负责，从通知中心播放时也需执行
  /// 开始心跳检测，单例
  static void _startHeartbeat({
    required String bvid,
    required int cid,
    required MediaPlayer player,
  }) {
    final playedMilliseconds = player.currentPosition.inMilliseconds;
    _heartbeatTimer.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      debugPrint('心跳检测模拟: $bvid, $cid, $playedMilliseconds');
      // TODO: 心跳检测网络请求
      // await VideoHttp.heartBeat(
      //   bvid: bvid,
      //   cid: cid,
      //   progress: playedMilliseconds,
      // );
    });
  }

  bool _wasPlaying = false;

  Stream<bool> get playingStream =>
      _player?.playingStream ?? const Stream<bool>.empty();

  Stream<Duration> get positionStream =>
      _player?.positionStream ?? const Stream<Duration>.empty();

  Stream<Duration> get durationStream =>
      _player?.durationStream ?? const Stream<Duration>.empty();

  Stream<bool> get bufferingStream =>
      _player?.bufferingStream ?? const Stream<bool>.empty();

  Duration get currentPosition => _player?.currentPosition ?? Duration.zero;

  Duration get currentDuration =>
      _player?.currentDuration ?? const Duration(seconds: 1);

  bool get isPlaying => _player?.isPlaying ?? false;

  bool get isBuffering => _player?.isBuffering ?? false;
  Future<void> seekByProgress(double progress) async {
    final duration = currentDuration;
    final position = duration * progress;
    await _player?.seek(position);
  }

  double? _draggingProgress;

  double? get draggingProgress => _draggingProgress;

  void onProgressDragUpdate(DragUpdateDetails details, double progress) {
    final curProgress =
        _draggingProgress ??
        currentPosition.inMilliseconds / currentDuration.inMilliseconds;
    final newP = curProgress + details.delta.dx / 500;
    _draggingProgress = newP.clamp(0, 1);
  }

  Future<void> onProgressDragEnd(
    DragEndDetails details,
    double progress,
  ) async {
    await _player?.seek(currentDuration * (_draggingProgress ?? progress));
    _draggingProgress = null;
  }

  Future<void> didPushNext(String? next, BuildContext context) async {
    _wasPlaying = _player?.isPlaying ?? false;
    // 下一个页面是视频页就暂停播放，否则浮窗播放
    next == Routes.video
        ? _pause()
        : _floatVideo(context, createFromPop: false);
  }

  Future<void> onPopNext(String? next) async {
    floatingManager.disposeAllFloating(); // 回到本视频页，不应该再有视频浮窗
    if (_wasPlaying) _play();
  }

  bool isVideoLandscape() {
    return (_player?.aspectRatio ?? 2) > 1.3;
  }

  void _pause() {
    _player?.pause();
    _stopHeartbeat();
  }

  Future<void> _play() async {
    await _player?.play();
    MediaS.i.setMedia(
      player: _player,
      media: MediaItem(
        id: bvid,
        title: _detail?.title ?? '',
        artist: _detail?.owner.name ?? '',
        duration: currentDuration,
        // 封面为空也不显示
        artUri: Uri.parse(_detail?.pic ?? ''),
      ),
    );
    final cid = getCid();
    if (cid == null || _player == null) return;
    _startHeartbeat(bvid: _bvid, cid: cid, player: _player!);
  }

  double getAspectRatio() => _player?.aspectRatio ?? 16 / 9;

  void playOrPause() {
    if (_player == null) return;
    _player!.isPlaying ? _pause() : _play();
  }

  Future<PlayingInfoM> getPlayingInfo() async {
    return await _player?.getPlayingInfo() ?? PlayingInfoM();
  }

  void didPop(String? pre, BuildContext context) {
    // 如果上一个页面不是视频页就需要浮窗播放视频, 否则释放播放器
    var needFloat = pre != Routes.video;
    needFloat ? _floatVideo(context, createFromPop: true) : _player?.dispose();
  }

  void _floatVideo(BuildContext context, {required bool createFromPop}) {
    floatingManager.disposeAllFloating();
    if (_player == null) return;
    final floatingOverlay = FloatingOverlay(
      FloatVideoV(
        aspectRatio: getAspectRatio(),
        player: _player!,
        createFromPop: createFromPop,
      ),
      params: FloatingParams(isSnapToEdge: false),
    );
    floatingManager.createFloating('floatingVideo', floatingOverlay);
    floatingOverlay.open(context);
  }

  Future<void> onVerticalDragUpdate(
    DragUpdateDetails details,
    double maxWidth,
  ) async {
    var dx = details.localPosition.dx;
    final k = OS.isPCOS ? 0.002 : 0.01;
    var delta = -k * details.delta.dy;
    if (dx > maxWidth / 2) {
      // 调整音量
      final value =
          ((await FlutterVolumeController.getVolume()) ?? 0.5) + delta;
      FlutterVolumeController.updateShowSystemUI(false);
      FlutterVolumeController.setVolume(value.clamp(0, 1));
    } else {
      // 调整屏幕亮度
      canChangeSystemBrightness ??=
          await ScreenBrightness().canChangeSystemBrightness;
      if (canChangeSystemBrightness ?? false) {
        final value = ((await ScreenBrightness().system) + delta);
        ScreenBrightness().setSystemScreenBrightness(value.clamp(0, 1));
      } else {
        final value = (await ScreenBrightness().application) + delta;
        ScreenBrightness().setApplicationScreenBrightness(value.clamp(0, 1));
      }
    }
  }

  static bool? canChangeSystemBrightness;
}

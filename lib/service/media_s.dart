import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bili/core/http/video_http.dart';
import 'package:flutter_bili/module/setting/model/setting_m.dart';
import 'package:flutter_bili/module/video/model/play_url_model.dart';
import 'package:flutter_bili/module/video/model/playing_info_m.dart';
import 'package:flutter_bili/module/video/model/video_quality_m.dart';
import 'package:flutter_bili/module/video/widget/fvp_video_v.dart';
import 'package:flutter_bili/module/video/widget/media_kit_video_v.dart';
import 'package:flutter_bili/service/storage_s.dart';
import 'package:fvp/fvp.dart' as fvp;
// 使用MdkVideoPlayerPlatform
// ignore: implementation_imports
import 'package:fvp/src/video_player_mdk.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

/// 处理媒体播放服务
class MediaS extends BaseAudioHandler with ChangeNotifier, SeekHandler {
  MediaS._();

  static late final MdkVideoPlayerPlatform _fvpPlatform;

  static final MediaS i = MediaS._();

  static void initLib([PlayerLibraryM? playerLibrary]) {
    playerLibrary ??= StorageS.getSetting().playerLibrary;
    switch (playerLibrary) {
      case PlayerLibraryM.mediaKit:
        MediaKit.ensureInitialized();
      case PlayerLibraryM.fvp:
        fvp.registerWith(
          options: {
            'video.decoders': [
              'VideoToolbox',
              'MediaCodec',
              'D3D11',
              'NVDEC',
              'FFmpeg',
            ],
          },
        );
        _fvpPlatform = VideoPlayerPlatform.instance as MdkVideoPlayerPlatform;
    }
  }

  // ── media_kit backend ──────────────────────────────────────────────────────
  Player? _mkPlayer;
  VideoController? _mkController;

  // ── fvp backend ────────────────────────────────────────────────────────────
  VideoPlayerController? _fvpController;
  StreamController<bool>? _fvpPlayingCtrl;
  StreamController<Duration>? _fvpPositionCtrl;
  StreamController<Duration>? _fvpDurationCtrl;
  StreamController<bool>? _fvpBufferingCtrl;

  // ── heartbeat ──────────────────────────────────────────────────────────────
  Timer? _heartbeatTimer;
  String _bvid = '';
  int _cid = 0;

  // ── play url ───────────────────────────────────────────────────────────────
  PlayUrlModel? _playUrl;

  // ── state ──────────────────────────────────────────────────────────────────
  PlayerLibraryM _currentLibrary = PlayerLibraryM.mediaKit;

  PlayerLibraryM get currentLibrary => _currentLibrary;

  bool get isInitialized => _mkPlayer != null || _fvpController != null;

  // ── unified streams ────────────────────────────────────────────────────────

  Stream<bool> get playingStream {
    if (_currentLibrary == PlayerLibraryM.mediaKit && _mkPlayer != null) {
      return _mkPlayer!.stream.playing;
    }
    return _fvpPlayingCtrl?.stream ?? const Stream<bool>.empty();
  }

  Stream<Duration> get positionStream {
    if (_currentLibrary == PlayerLibraryM.mediaKit && _mkPlayer != null) {
      return _mkPlayer!.stream.position;
    }
    return _fvpPositionCtrl?.stream ?? const Stream<Duration>.empty();
  }

  Stream<Duration> get durationStream {
    if (_currentLibrary == PlayerLibraryM.mediaKit && _mkPlayer != null) {
      return _mkPlayer!.stream.duration;
    }
    return _fvpDurationCtrl?.stream ?? const Stream<Duration>.empty();
  }

  Stream<bool> get bufferingStream {
    if (_currentLibrary == PlayerLibraryM.mediaKit && _mkPlayer != null) {
      return _mkPlayer!.stream.buffering;
    }
    return _fvpBufferingCtrl?.stream ?? const Stream<bool>.empty();
  }

  double getAspectRatio() {
    var aspectRatio = 16 / 9;
    if (_mkPlayer != null) {
      final aspect = _mkPlayer!.platform?.state.videoParams.aspect;
      if (aspect != null) {
        aspectRatio = aspect;
      }
    } else if (_fvpController != null) {
      aspectRatio = _fvpController!.value.aspectRatio;
    }
    return aspectRatio;
  }

  // ── lifecycle ──────────────────────────────────────────────────────────────

  Future<void> initAndLoad(
    PlayUrlModel playUrl, {
    required String bvid,
    required int cid,
  }) async {
    _playUrl = playUrl;
    _bvid = bvid;
    _cid = cid;

    final setting = StorageS.getSetting();
    _currentLibrary = setting.playerLibrary;

    await disposePlayer();

    final videoUrl = playUrl.dash?.video?.first.baseUrl;
    if (videoUrl == null || videoUrl.isEmpty) return;

    const headers = {
      'referer': 'https://www.bilibili.com',
      'user-agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
    };

    try {
      if (_currentLibrary == PlayerLibraryM.mediaKit) {
        await _initMediaKit(videoUrl, playUrl, headers);
      } else {
        await _initFvp(videoUrl, playUrl, headers);
      }
      _startHeartbeat();
      notifyListeners();
    } on Exception catch (e) {
      debugPrint('MediaS initAndLoad failed: $e');
    }
  }

  Future<void> disposePlayer() async {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _playUrl = null;

    if (_mkPlayer != null) {
      await _mkPlayer!.dispose();
      _mkPlayer = null;
      _mkController = null;
    }

    if (_fvpController != null) {
      _fvpController!.removeListener(_onFvpUpdate);
      await _fvpController!.dispose();
      _fvpController = null;
      _disposeFvpStreams();
    }

    notifyListeners();
  }

  Future<PlayingInfoM> getPlayingInfo() async {
    if (_currentLibrary == PlayerLibraryM.mediaKit && _mkPlayer != null) {
      return _getMediaKitPlayingInfo();
    } else if (_fvpController != null) {
      return _getFvpPlayingInfo();
    }
    return PlayingInfoM();
  }

  Future<PlayingInfoM> _getMediaKitPlayingInfo() async {
    final state = _mkPlayer!.state;
    final videoParams = state.videoParams;

    String? decoder;
    String? codec;
    var frameRate = 0.0;

    final nativePlayer = _mkPlayer!.platform as NativePlayer?;
    if (nativePlayer != null) {
      try {
        final hwdec = await nativePlayer.getProperty('hwdec-current');
        if (hwdec.isNotEmpty && hwdec != 'no') {
          decoder = hwdec;
        }
        final videoCodec = await nativePlayer.getProperty('video-codec');
        if (videoCodec.isNotEmpty) {
          codec = videoCodec;
        }
        final fps = await nativePlayer.getProperty('container-fps');
        if (fps.isNotEmpty) {
          frameRate = double.tryParse(fps) ?? 0.0;
        }
      } on Exception catch (_) {}
    }

    return PlayingInfoM(
      width: videoParams.w ?? state.width,
      height: videoParams.h ?? state.height,
      codec: codec,
      decoder: decoder,
      quality: _getQualityName(),
      pixelFormat: videoParams.pixelformat,
      frameRate: frameRate > 0 ? frameRate : null,
    );
  }

  PlayingInfoM _getFvpPlayingInfo() {
    final value = _fvpController!.value;
    final mediaInfo = _fvpController!.getMediaInfo();
    final videoStream = mediaInfo?.video?.firstOrNull;
    final videoCodec = videoStream?.codec;
    // // ignore: invalid_use_of_visible_for_testing_member
    // final id = _fvpController!.playerId;
    // final decoder;

    return PlayingInfoM(
      width: videoCodec?.width ?? value.size.width.toInt(),
      height: videoCodec?.height ?? value.size.height.toInt(),
      codec: videoCodec?.codec.isNotEmpty ?? false ? videoCodec?.codec : null,
      quality: _getQualityName(),
      pixelFormat: videoCodec?.formatName,
      frameRate: videoCodec != null && videoCodec.frameRate > 0
          ? videoCodec.frameRate
          : null,
    );
  }

  String? _getQualityName() {
    final quality = _playUrl?.quality;
    if (quality == null) return null;
    return VideoQualityM.values
        .cast<VideoQualityM?>()
        .firstWhere(
          (e) => e!.qn == quality,
          orElse: () => null,
        )
        ?.name;
  }

  // ── media_kit backend ───────────────────────────────────────────────────────

  Future<void> _initMediaKit(
    String videoUrl,
    PlayUrlModel playUrl,
    Map<String, String> headers,
  ) async {
    _mkPlayer = Player();
    _mkController = VideoController(_mkPlayer!);

    final audioUrl = playUrl.dash?.audio?.first.baseUrl;
    if (audioUrl != null && audioUrl.isNotEmpty) {
      final nativePlayer = _mkPlayer!.platform as NativePlayer?;
      if (nativePlayer != null) {
        await nativePlayer.waitForPlayerInitialization;
        await _mkPlayer!.setAudioTrack(AudioTrack.auto());
        final processedAudioUrl = audioUrl.replaceAll(':', r'\:');
        await nativePlayer.setProperty('audio-files', processedAudioUrl);
      }
    }

    await _mkPlayer!.open(
      Media(videoUrl, httpHeaders: headers),
    );
  }

  // ── fvp backend ─────────────────────────────────────────────────────────────

  Future<void> _initFvp(
    String videoUrl,
    PlayUrlModel playUrl,
    Map<String, String> headers,
  ) async {
    _initFvpStreams();
    _fvpController = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
      httpHeaders: headers,
    );
    await _fvpController!.initialize();
    if (Platform.operatingSystem == 'ohos') {
      _fvpController!.setVideoDecoders([
        'OH',
        'ohcodec:copy=1',
        'FFmpeg',
        'dav1d',
      ]);
    }
    final audioUrl = playUrl.dash?.audio?.first.baseUrl;
    if (audioUrl != null) _fvpController!.setExternalAudio(audioUrl);

    _fvpController!.addListener(_onFvpUpdate);
    _onFvpUpdate();
    await _fvpController!.play();
  }

  void _initFvpStreams() {
    _fvpPlayingCtrl = StreamController<bool>.broadcast();
    _fvpPositionCtrl = StreamController<Duration>.broadcast();
    _fvpDurationCtrl = StreamController<Duration>.broadcast();
    _fvpBufferingCtrl = StreamController<bool>.broadcast();
  }

  void _disposeFvpStreams() {
    _fvpPlayingCtrl?.close();
    _fvpPositionCtrl?.close();
    _fvpDurationCtrl?.close();
    _fvpBufferingCtrl?.close();
    _fvpPlayingCtrl = null;
    _fvpPositionCtrl = null;
    _fvpDurationCtrl = null;
    _fvpBufferingCtrl = null;
  }

  void _onFvpUpdate() {
    if (_fvpController == null) return;
    final value = _fvpController!.value;
    _fvpPlayingCtrl?.add(value.isPlaying);
    _fvpPositionCtrl?.add(value.position);
    _fvpDurationCtrl?.add(value.duration);
    _fvpBufferingCtrl?.add(value.isBuffering);
  }

  // ── heartbeat ───────────────────────────────────────────────────────────────

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (_bvid.isEmpty || _cid == 0) return;
      await VideoHttp.heartBeat(
        bvid: _bvid,
        cid: _cid,
        progress: _currentPosition.inSeconds,
      );
    });
  }

  Duration get currentPosition {
    if (_currentLibrary == PlayerLibraryM.mediaKit && _mkPlayer != null) {
      return _mkPlayer!.state.position;
    } else if (_fvpController != null) {
      return _fvpController!.value.position;
    }
    return Duration.zero;
  }

  Duration get currentDuration {
    if (_currentLibrary == PlayerLibraryM.mediaKit && _mkPlayer != null) {
      return _mkPlayer!.state.duration;
    } else if (_fvpController != null) {
      return _fvpController!.value.duration;
    }
    return const Duration(seconds: 1); // 防止除数为0
  }

  bool get isPlaying {
    if (_currentLibrary == PlayerLibraryM.mediaKit && _mkPlayer != null) {
      return _mkPlayer!.state.playing;
    } else if (_fvpController != null) {
      return _fvpController!.value.isPlaying;
    }
    return false;
  }

  bool get isBuffering {
    if (_currentLibrary == PlayerLibraryM.mediaKit && _mkPlayer != null) {
      return _mkPlayer!.state.buffering;
    } else if (_fvpController != null) {
      return _fvpController!.value.isBuffering;
    }
    return false;
  }

  Duration get _currentPosition => currentPosition;

  // ── playback controls ───────────────────────────────────────────────────────

  @override
  Future<void> play() async {
    if (_currentLibrary == PlayerLibraryM.mediaKit && _mkPlayer != null) {
      await _mkPlayer!.play();
    } else if (_fvpController != null) {
      await _fvpController!.play();
    }
    await super.play();
  }

  @override
  Future<void> pause() async {
    if (_currentLibrary == PlayerLibraryM.mediaKit && _mkPlayer != null) {
      await _mkPlayer!.pause();
    } else if (_fvpController != null) {
      await _fvpController!.pause();
    }
    await super.pause();
  }

  Future<void> playOrPause() async {
    if (_currentLibrary == PlayerLibraryM.mediaKit && _mkPlayer != null) {
      await _mkPlayer!.playOrPause();
    } else if (_fvpController != null) {
      if (_fvpController!.value.isPlaying) {
        await _fvpController!.pause();
      } else {
        await _fvpController!.play();
      }
    }
  }

  Future<void> seekByProgress(double progress) async {
    final duration = currentDuration;
    final position = duration * progress;
    await seek(position);
  }

  @override
  Future<void> seek(Duration position) async {
    if (_currentLibrary == PlayerLibraryM.mediaKit && _mkPlayer != null) {
      await _mkPlayer!.seek(position);
    } else if (_fvpController != null) {
      await _fvpController!.seekTo(position);
    }
  }

  Future<void> setVolume(double volume) async {
    if (_currentLibrary == PlayerLibraryM.mediaKit && _mkPlayer != null) {
      await _mkPlayer!.setVolume(volume * 100);
    } else if (_fvpController != null) {
      await _fvpController!.setVolume(volume);
    }
  }

  // ── widget access ───────────────────────────────────────────────────────────

  Widget buildVideoView() {
    if (_currentLibrary == PlayerLibraryM.mediaKit && _mkController != null) {
      return MediaKitVideoV(controller: _mkController!);
    }
    if (_fvpController != null) {
      return FvpVideoV(controller: _fvpController!);
    }
    return const SizedBox.shrink();
  }

  double? _draggingProgress;

  double? get draggingProgress => _draggingProgress;

  void onProgressDragUpdate(DragUpdateDetails details, double progress) {
    final curProgress =
        _draggingProgress ??
        currentPosition.inMilliseconds / currentDuration.inMilliseconds;
    final newP = curProgress + details.delta.dx / 500;
    _draggingProgress = newP.clamp(0, 1);
    notifyListeners();
  }

  Future<void> onProgressDragEnd(
    DragEndDetails details,
    double progress,
  ) async {
    await seek(currentDuration * (_draggingProgress ?? progress));
    _draggingProgress = null;
    notifyListeners();
  }
}

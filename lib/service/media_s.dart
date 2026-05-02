import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bili/core/http/video_http.dart';
import 'package:flutter_bili/infrastructure/media_player/media_player.dart';
import 'package:flutter_bili/module/setting/model/setting_m.dart';
import 'package:flutter_bili/module/video/model/playing_info_m.dart';
import 'package:flutter_bili/service/storage_s.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'package:media_kit/media_kit.dart';

/// 处理媒体播放服务
class MediaS extends BaseAudioHandler with ChangeNotifier, SeekHandler {
  MediaS._();

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
    }
  }

  MediaPlayer? player;

  set player(MediaPlayer? value) {
    if (value == player) return;
    player?.dispose();
    player = value;
    notifyListeners();
  }

  // ── heartbeat ──────────────────────────────────────────────────────────────
  Timer? _heartbeatTimer;
  String _bvid = '';
  int _cid = 0;

  void startHeartbeat({required String bvid, required int cid}) {
    _bvid = bvid;
    _cid = cid;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (_bvid.isEmpty || _cid == 0) return;
      await VideoHttp.heartBeat(
        bvid: _bvid,
        cid: _cid,
        progress: currentPosition.inSeconds,
      );
    });
  }

  void stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _bvid = '';
    _cid = 0;
  }

  // ── state delegates ────────────────────────────────────────────────────────

  bool get isInitialized => player != null;

  Stream<bool> get playingStream =>
      player?.playingStream ?? const Stream<bool>.empty();

  Stream<Duration> get positionStream =>
      player?.positionStream ?? const Stream<Duration>.empty();

  Stream<Duration> get durationStream =>
      player?.durationStream ?? const Stream<Duration>.empty();

  Stream<bool> get bufferingStream =>
      player?.bufferingStream ?? const Stream<bool>.empty();

  double getAspectRatio() => player?.aspectRatio ?? 16 / 9;

  // ── lifecycle ──────────────────────────────────────────────────────────────

  Future<void> disposePlayer() async {
    stopHeartbeat();
    await player?.dispose();
    player = null;
    notifyListeners();
  }

  // ── playing info ───────────────────────────────────────────────────────────

  Future<PlayingInfoM> getPlayingInfo() async {
    return await player?.getPlayingInfo() ?? PlayingInfoM();
  }

  // ── position / duration ────────────────────────────────────────────────────

  Duration get currentPosition => player?.currentPosition ?? Duration.zero;

  Duration get currentDuration =>
      player?.currentDuration ?? const Duration(seconds: 1);

  bool get isPlaying => player?.isPlaying ?? false;

  bool get isBuffering => player?.isBuffering ?? false;

  // ── playback controls ───────────────────────────────────────────────────────

  @override
  Future<void> play() async {
    await player?.play();
    await super.play();
  }

  @override
  Future<void> pause() async {
    await player?.pause();
    await super.pause();
  }

  Future<void> playOrPause() async {
    await player?.playOrPause();
  }

  Future<void> seekByProgress(double progress) async {
    final duration = currentDuration;
    final position = duration * progress;
    await seek(position);
  }

  @override
  Future<void> seek(Duration position) async => player?.seek(position);

  Future<void> setVolume(double volume) async => player?.setVolume(volume);

  Widget buildVideoView() =>
      player?.buildVideoView() ?? const SizedBox.shrink();

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

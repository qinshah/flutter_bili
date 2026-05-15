import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
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
        fvp.registerWith();
    }
  }

  MediaPlayer? _player;

  // 只写
  // ignore: avoid_setters_without_getters
  set player(MediaPlayer? player) => _player = player;

  bool get isInitialized => _player != null;

  Stream<bool> get playingStream =>
      _player?.playingStream ?? const Stream<bool>.empty();

  Stream<Duration> get positionStream =>
      _player?.positionStream ?? const Stream<Duration>.empty();

  Stream<Duration> get durationStream =>
      _player?.durationStream ?? const Stream<Duration>.empty();

  Stream<bool> get bufferingStream =>
      _player?.bufferingStream ?? const Stream<bool>.empty();

  double getAspectRatio() => _player?.aspectRatio ?? 16 / 9;

  // ── lifecycle ──────────────────────────────────────────────────────────────

  // Future<void> disposePlayer() async {
  //   stopHeartbeat();
  //   await _player?.dispose();
  //   _player = null;
  //   notifyListeners();
  // }

  // ── playing info ───────────────────────────────────────────────────────────

  Future<PlayingInfoM> getPlayingInfo() async {
    return await _player?.getPlayingInfo() ?? PlayingInfoM();
  }

  // ── position / duration ────────────────────────────────────────────────────

  Duration get currentPosition => _player?.currentPosition ?? Duration.zero;

  Duration get currentDuration =>
      _player?.currentDuration ?? const Duration(seconds: 1);

  bool get isPlaying => _player?.isPlaying ?? false;

  bool get isBuffering => _player?.isBuffering ?? false;

  // ── playback controls ───────────────────────────────────────────────────────

  @override
  Future<void> play() async => _player?.play();

  @override
  Future<void> pause() async => _player?.pause();

  Future<void> playOrPause() async => _player?.playOrPause();

  Future<void> seekByProgress(double progress) async {
    final duration = currentDuration;
    final position = duration * progress;
    await seek(position);
  }

  @override
  Future<void> seek(Duration position) async => _player?.seek(position);

  Future<void> setVolume(double volume) async => _player?.setVolume(volume);

  // Widget buildVideoView() =>
  //     _player?.buildVideoView() ?? const SizedBox.shrink();

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

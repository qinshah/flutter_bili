import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bili/infrastructure/media_player/mdk_video_docoder.dart';
import 'package:flutter_bili/infrastructure/media_player/media_player.dart';
import 'package:flutter_bili/module/video/model/play_url_model.dart';
import 'package:flutter_bili/module/video/model/playing_info_m.dart';
import 'package:flutter_bili/module/video/widget/fvp_video_v.dart';
import 'package:fvp/fvp.dart';
import 'package:video_player/video_player.dart';

class FvpPlayer extends MediaPlayer {
  FvpPlayer._(this._controller, this._quality);

  final VideoPlayerController _controller;
  final String? _quality;

  final _playingCtrl = StreamController<bool>.broadcast();
  final _positionCtrl = StreamController<Duration>.broadcast();
  final _durationCtrl = StreamController<Duration>.broadcast();
  final _bufferingCtrl = StreamController<bool>.broadcast();

  MdkVideoDecoder? _deCoder;

  static Future<FvpPlayer> create(
    PlayUrlModel playUrl, {
    Map<String, String>? headers,
    Duration? startPosition,
  }) async {
    final videoUrl = playUrl.dash?.video?.firstOrNull?.baseUrl;
    if (videoUrl == null || videoUrl.isEmpty) {
      throw Exception('No video URL available');
    }

    final effectiveHeaders =
        headers ??
        const {
          'referer': 'https://www.bilibili.com',
          'user-agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
        };

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
      httpHeaders: effectiveHeaders,
    );
    await controller.initialize();

    final audioUrl = playUrl.dash?.audio?.firstOrNull?.baseUrl;
    if (audioUrl != null) controller.setExternalAudio(audioUrl);

    MdkVideoDecoder? deCoder;
    if (Platform.operatingSystem == 'ohos') {
      deCoder = MdkVideoDecoder.OH;
    }
    if (deCoder != null) controller.setVideoDecoders([deCoder.name]);

    final player = FvpPlayer._(controller, playUrl.quality?.toString());
    player._deCoder = deCoder;
    controller.addListener(player._onUpdate);
    player._onUpdate();

    if (startPosition != null && startPosition > Duration.zero) {
      await controller.seekTo(startPosition);
    }

    await controller.play();

    return player;
  }

  void _onUpdate() {
    final value = _controller.value;
    _playingCtrl.add(value.isPlaying);
    _positionCtrl.add(value.position);
    _durationCtrl.add(value.duration);
    _bufferingCtrl.add(value.isBuffering);
  }

  @override
  Stream<bool> get playingStream => _playingCtrl.stream;

  @override
  Stream<Duration> get positionStream => _positionCtrl.stream;

  @override
  Stream<Duration> get durationStream => _durationCtrl.stream;

  @override
  Stream<bool> get bufferingStream => _bufferingCtrl.stream;

  @override
  bool get isPlaying => _controller.value.isPlaying;

  @override
  bool get isBuffering => _controller.value.isBuffering;

  @override
  Duration get currentPosition => _controller.value.position;

  @override
  Duration get currentDuration => _controller.value.duration;

  @override
  double get aspectRatio => _controller.value.aspectRatio;

  @override
  Future<void> play() => _controller.play();

  @override
  Future<void> pause() => _controller.pause();

  @override
  Future<void> seek(Duration position) => _controller.seekTo(position);

  @override
  Future<void> playOrPause() => isPlaying ? pause() : play();

  @override
  Future<void> setVolume(double volume) => _controller.setVolume(volume);

  @override
  Widget buildVideoView() => FvpVideoV(controller: _controller);

  @override
  Future<PlayingInfoM> getPlayingInfo() async {
    final value = _controller.value;
    final mediaInfo = _controller.getMediaInfo();
    final videoStream = mediaInfo?.video?.firstOrNull;
    final videoCodec = videoStream?.codec;

    return PlayingInfoM(
      width: videoCodec?.width ?? value.size.width.toInt(),
      height: videoCodec?.height ?? value.size.height.toInt(),
      decoder: _deCoder == null ? '未知(默认)' : _deCoder.toString(),
      codec: videoCodec?.codec.isNotEmpty ?? false ? videoCodec?.codec : null,
      quality: _quality,
      pixelFormat: videoCodec?.formatName,
      frameRate: videoCodec != null && videoCodec.frameRate > 0
          ? videoCodec.frameRate
          : null,
    );
  }

  @override
  Future<void> dispose() async {
    _controller.removeListener(_onUpdate);
    await _controller.setVolume(0);
    await _controller.play(); // 奇怪的bug，以暂停状态dispose会导致UI线程锁死
    Future.wait([
      _playingCtrl.close(),
      _positionCtrl.close(),
      _durationCtrl.close(),
      _bufferingCtrl.close(),
      _controller.dispose(),
    ]);
  }
}

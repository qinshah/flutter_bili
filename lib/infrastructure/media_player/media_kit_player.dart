import 'package:flutter/material.dart';
import 'package:flutter_bili/infrastructure/media_player/media_player.dart';
import 'package:flutter_bili/module/video/model/play_url_model.dart';
import 'package:flutter_bili/module/video/model/playing_info_m.dart';
import 'package:flutter_bili/module/video/widget/media_kit_video_v.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MediaKitPlayer extends MediaPlayer {
  MediaKitPlayer._(this._player, this._controller, this._quality);

  final Player _player;
  final VideoController _controller;
  final String? _quality;

  static Future<MediaKitPlayer> create(
    PlayUrlModel playUrl, {
    Map<String, String>? headers,
    Duration? startPosition,
  }) async {
    final player = Player();
    final controller = VideoController(player);

    final videoUrl = playUrl.dash?.video?.firstOrNull?.baseUrl;
    if (videoUrl == null || videoUrl.isEmpty) {
      throw Exception('No video URL available');
    }

    final effectiveHeaders = headers ?? const {
      'referer': 'https://www.bilibili.com',
      'user-agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
    };

    final audioUrl = playUrl.dash?.audio?.firstOrNull?.baseUrl;
    if (audioUrl != null && audioUrl.isNotEmpty) {
      final nativePlayer = player.platform as NativePlayer?;
      if (nativePlayer != null) {
        await nativePlayer.waitForPlayerInitialization;
        await player.setAudioTrack(AudioTrack.auto());
        final processedAudioUrl = audioUrl.replaceAll(':', r'\:');
        await nativePlayer.setProperty('audio-files', processedAudioUrl);
      }
    }

    await player.open(
      Media(videoUrl, httpHeaders: effectiveHeaders),
    );

    if (startPosition != null && startPosition > Duration.zero) {
      await player.seek(startPosition);
    }

    return MediaKitPlayer._(player, controller, playUrl.quality?.toString());
  }

  @override
  Stream<bool> get playingStream => _player.stream.playing;

  @override
  Stream<Duration> get positionStream => _player.stream.position;

  @override
  Stream<Duration> get durationStream => _player.stream.duration;

  @override
  Stream<bool> get bufferingStream => _player.stream.buffering;

  @override
  bool get isPlaying => _player.state.playing;

  @override
  bool get isBuffering => _player.state.buffering;

  @override
  Duration get currentPosition => _player.state.position;

  @override
  Duration get currentDuration => _player.state.duration;

  @override
  double get aspectRatio {
    final aspect = _player.platform?.state.videoParams.aspect;
    return aspect ?? 16 / 9;
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> playOrPause() => _player.playOrPause();

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume * 100);

  @override
  Widget buildVideoView() => MediaKitVideoV(controller: _controller);

  @override
  Future<PlayingInfoM> getPlayingInfo() async {
    final state = _player.state;
    final videoParams = state.videoParams;

    String? decoder;
    String? codec;
    var frameRate = 0.0;

    final nativePlayer = _player.platform as NativePlayer?;
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
      quality: _quality,
      pixelFormat: videoParams.pixelformat,
      frameRate: frameRate > 0 ? frameRate : null,
    );
  }

  @override
  Future<void> dispose() => _player.dispose();
}

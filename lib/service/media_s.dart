import 'dart:async';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_bili/infrastructure/media_player/media_player.dart';
import 'package:flutter_bili/module/setting/model/setting_m.dart';
import 'package:flutter_bili/service/storage_s.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'package:media_kit/media_kit.dart';

/// 处理媒体播放服务
class MediaS extends BaseAudioHandler with SeekHandler {
  MediaS._();

  static final MediaS i = MediaS._();

  static void initLib([PlayerKernel? playerLibrary]) {
    playerLibrary ??= StorageS.getSetting().playerKernel;
    switch (playerLibrary) {
      case PlayerKernel.mpv:
        MediaKit.ensureInitialized();
      case PlayerKernel.mdk:
        fvp.registerWith();
    }
  }

  late final AudioSession _audioSession;

  Future<void> init() async {
    // 初始化 AudioHandler 用于系统媒体通知
    await AudioService.init(
      builder: () => this,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: true,
      ),
    );
    _audioSession = await AudioSession.instance;
    _audioSession.setActive(true);
  }

  MediaPlayer? _player;

  StreamSubscription<bool> _playingSubscription = const Stream<bool>.empty()
      .listen(null);

  void setMedia({required MediaItem media, MediaPlayer? player}) {
    mediaItem.add(media);
    _playingSubscription.cancel();
    _audioSession.setActive(true);
    if (player != null) _listen(player);
    _player = player;
  }

  void _listen(MediaPlayer player) {
    _playingSubscription = player.playingStream.listen((playing) {
      playbackState.add(
        PlaybackState(
          playing: playing,
          processingState: playing
              ? AudioProcessingState.completed
              : AudioProcessingState.ready,
          updatePosition: player.currentPosition,
        ),
      );
    });
    // _posSubscription = player.positionStream.listen((position) {
    //   playbackState.add(
    //     PlaybackState(
    //       controls: [MediaControl.pause, MediaControl.stop],
    //       processingState: AudioProcessingState.ready,
    //       playing: true,
    //     ),
    //   );
    // });
  }

  @override
  Future<void> play() async => _player?.play();

  @override
  Future<void> pause() async => _player?.pause();

  Future<void> playOrPause() async => _player?.playOrPause();

  @override
  Future<void> seek(Duration position) async => _player?.seek(position);

  Future<void> setVolume(double volume) async => _player?.setVolume(volume);

  // 防止切后台暂停播放
  StreamSubscription<bool>? _backPlayingSub;
  void onAppLifecycleChanged(AppLifecycleState state) {
    if (_player == null ||
        !_player!.isPlaying ||
        state == AppLifecycleState.resumed) {
      return;
    }
    _backPlayingSub?.cancel();
    _backPlayingSub = _player!.playingStream.listen((playing) {
      if (playing) return;
      _player!.play();
      _backPlayingSub?.cancel();
    });
    // 3秒后停止检查
    Future.delayed(const Duration(seconds: 3)).then((_) {
      _backPlayingSub?.cancel();
    });
  }
}

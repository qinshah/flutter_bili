import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_bili/infrastructure/media_player/media_player.dart';
import 'package:flutter_bili/module/setting/model/setting_m.dart';
import 'package:flutter_bili/service/storage_s.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'package:media_kit/media_kit.dart';

/// 处理媒体播放服务
class MediaS extends BaseAudioHandler with SeekHandler {
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

  void setPlayer(MediaPlayer? player) => _player = player;

  @override
  Future<void> play() async => _player?.play();

  @override
  Future<void> pause() async => _player?.pause();

  Future<void> playOrPause() async => _player?.playOrPause();

  @override
  Future<void> seek(Duration position) async => _player?.seek(position);

  Future<void> setVolume(double volume) async => _player?.setVolume(volume);
}

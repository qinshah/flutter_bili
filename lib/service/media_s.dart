import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bili/service/storage_s.dart';

/// 处理媒体播放服务
class MediaS extends BaseAudioHandler with ChangeNotifier, SeekHandler {
  MediaS._();

  static final MediaS i = MediaS._();

  @override
  Future<void> play() {
    final playerLibrary = StorageS.getLocal().playerLibrary;
    return super.play();
  }

  @override
  Future<void> pause() {
    // TODO: implement pause
    return super.pause();
  }
}

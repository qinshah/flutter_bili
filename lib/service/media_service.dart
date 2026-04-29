import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';

/// 处理媒体播放服务
class MediaService extends BaseAudioHandler with ChangeNotifier, SeekHandler {
  MediaService._();

  static final MediaService i = MediaService._();
}

import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MediaKitVideoV extends StatelessWidget {
  const MediaKitVideoV({required this.controller, super.key});

  final VideoController controller;

  @override
  Widget build(BuildContext context) {
    return Video(
      controller: controller,
      controls: null, // 关闭 media_kit 内置 SubtitleView，避免与外层叠加重复
      subtitleViewConfiguration: const SubtitleViewConfiguration(
        visible: false,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MediaKitVideoV extends StatelessWidget {
  const MediaKitVideoV({required this.controller, super.key});

  final VideoController controller;

  @override
  Widget build(BuildContext context) {
    return Video(controller: controller);
  }
}

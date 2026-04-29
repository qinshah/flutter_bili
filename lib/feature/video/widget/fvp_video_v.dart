import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FvpVideoV extends StatelessWidget {
  const FvpVideoV({required this.controller, super.key});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return VideoPlayer(controller);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bili/infrastructure/media_player/media_player.dart';
import 'package:flutter_floating/floating/manager/floating_manager.dart';

class FloatVideoV extends StatefulWidget {
  const FloatVideoV({
    super.key,
    required this.aspectRatio,
    required this.player,
   required this.createFromPop,
  });

  final bool createFromPop;

  final double aspectRatio;

  final MediaPlayer player;

  @override
  State<FloatVideoV> createState() => _FloatVideoVState();
}

class _FloatVideoVState extends State<FloatVideoV> {
  @override
  dispose() {
    widget.player.pause();
    if (widget.createFromPop) widget.player.dispose(); // 关闭页面时创建的浮窗，需要释放播放器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: floatingManager.disposeAllFloating,
      child: SizedBox(
        width: 250,
        height: 250 / widget.aspectRatio,
        child: widget.player.buildVideoView(),
      ),
    );
  }
}

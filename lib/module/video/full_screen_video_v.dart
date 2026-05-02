import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bili/module/video/video_page_vm.dart';
import 'package:flutter_bili/module/video/widget/progress_v.dart';
import 'package:flutter_bili/module/video/widget/quality_button_v.dart';
import 'package:flutter_bili/service/media_s.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:u_service/u_service.dart';
import 'package:u_widget/u_widget.dart';
// ─── Page ─────────────────────────────────────────────────────────────────────

class FullScreenVideoV extends StatelessWidget {
  const FullScreenVideoV({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<VideoPageVm>();
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: UVideoPlayer(
        onProgressDragEnd: MediaS.i.onProgressDragEnd,
        onProgressDragUpdate: MediaS.i.onProgressDragUpdate,
        aspectRatio: MediaS.i.getAspectRatio(),
        onProgressTapDown: MediaS.i.seekByProgress,
        video: vm.buildVideoView(),
        onDoubleTapDown: (details) => details.kind == PointerDeviceKind.mouse
            ? _exitFullScreen(context)
            : MediaS.i.playOrPause(),
        onTogglePlay: MediaS.i.playOrPause,
        topLeft: (_) => BackButton(
          color: Colors.white,
          onPressed: () => _exitFullScreen(context),
        ),
        topRight: (_) => const Row(
          children: [Icon(Icons.info), Icon(Icons.more_vert)],
        ),
        topCenter: (_) => const Center(child: Text('标题')),
        centerLeft: (_) => const Icon(Icons.lock),
        centerRight: (_) => const Icon(Icons.camera),
        progressBuilder: (_) => const ProgressV(),
        center: (context, progress) {
          final duration = MediaS.i.currentDuration;
          final position = duration * progress;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_formatDuration(position)} / ${_formatDuration(duration)}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        },
        bottomLeft: (_) => StreamBuilder<bool>(
          stream: MediaS.i.playingStream,
          initialData: MediaS.i.isPlaying,
          builder: (_, snap) => IconButton(
            icon: Icon(
              snap.data ?? false ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: MediaS.i.playOrPause,
          ),
        ),
        bottomRight: (_) => Row(
          children: [
            QualityButtonV(videoPageVm: context.read<VideoPageVm>()),
            IconButton(
              onPressed: () => _exitFullScreen(context),
              icon: const Icon(
                Icons.fullscreen,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exitFullScreen(BuildContext context) async {
    context.pop();
    await USystemS.exitFullScreen();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bili/module/video/model/play_url_model.dart';
import 'package:flutter_bili/module/video/model/video_quality_m.dart';
import 'package:flutter_bili/module/video/video_page_vm.dart';
import 'package:flutter_bili/module/video/widget/progress_v.dart';
import 'package:flutter_bili/service/media_s.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:u_service/u_service.dart';
import 'package:u_widget/u_widget.dart';
// ─── Page ─────────────────────────────────────────────────────────────────────

class FullScreenVideoV extends StatefulWidget {
  const FullScreenVideoV({required this.bvid, super.key});

  final String bvid;

  @override
  State<FullScreenVideoV> createState() => _FullScreenVideoVState();
}

class _FullScreenVideoVState extends State<FullScreenVideoV> {
  final int _currentCid = 0;
  // ── Quality switching ───────────────────────────────────────────────────────

  Future<void> _showQualityPicker(PlayUrlModel playUrlM) async {
    final service = context.read<VideoPageVm>();
    final qualities = playUrlM.acceptQuality ?? [];
    if (qualities.isEmpty) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: qualities.map((qn) {
          final videoQuality = VideoQualityM.values.firstWhere(
            (e) => e.qn == qn,
            orElse: () => VideoQualityM.a1080p30,
          );
          final label = videoQuality.qn == qn
              ? videoQuality.name
              : qn.toString();
          return ListTile(
            title: Text(label),
            onTap: () async {
              Navigator.pop(ctx);
              await service.loadPlayUrl(widget.bvid, _currentCid, qn: qn);
              if (!mounted) return;
              if (service.playUrl != null) {
                await MediaS.i.initAndLoad(
                  service.playUrl!,
                  bvid: widget.bvid,
                  cid: _currentCid,
                );
              }
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: UVideoPlayer(
        aspectRatio: MediaS.i.getAspectRatio(),
        onProgressTapDown: MediaS.i.seekByProgress,
        video: MediaS.i.buildVideoView(),
        onDoubleTapDown: (details) => details.kind == PointerDeviceKind.mouse
            ? _exitFullScreen()
            : MediaS.i.playOrPause(),
        onTogglePlay: MediaS.i.playOrPause,
        topLeft: (_) => const BackButton(color: Colors.white),
        bottomRight: (_) => Row(
          children: [
            IconButton(
              onPressed: _exitFullScreen,
              icon: const Icon(
                Icons.fullscreen,
                color: Colors.white,
              ),
            ),
          ],
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
        onProgressDragEnd: MediaS.i.onProgressDragEnd,
        onProgressDragUpdate: MediaS.i.onProgressDragUpdate,
      ),
    );
  }

  Future<void> _exitFullScreen() async {
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

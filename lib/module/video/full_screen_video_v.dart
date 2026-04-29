import 'package:flutter/material.dart';
import 'package:flutter_bili/module/video/model/play_url_model.dart';
import 'package:flutter_bili/module/video/model/video_quality_m.dart';
import 'package:flutter_bili/module/video/video_page_vm.dart';
import 'package:flutter_bili/service/media_s.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
        video: MediaS.i.buildVideoView(),
        topLeft: (_) => const BackButton(),
        topRight: (_) =>
            const Row(children: [Icon(Icons.info), Icon(Icons.more_vert)]),
        topCenter: (_) => const Center(child: Text('标题')),
        centerLeft: (_) => const Icon(Icons.lock),
        centerRight: (_) => const Icon(Icons.camera),
        bottomCenter: (_) => const LinearProgressIndicator(),
        bottomLeft: (_) => const Row(children: [Icon(Icons.play_arrow)]),
        bottomRight: (_) => Row(
          children: [
            IconButton(
              onPressed: context.pop,
              icon: const Icon(Icons.fullscreen_exit),
            ),
          ],
        ),
      ),
    );
  }
}

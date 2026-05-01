import 'package:flutter/material.dart';
import 'package:flutter_bili/module/video/model/video_quality_m.dart';
import 'package:flutter_bili/module/video/video_page_vm.dart';
import 'package:flutter_bili/service/media_s.dart';
import 'package:provider/provider.dart';

class QualityButtonV extends StatefulWidget {
  const QualityButtonV({required this.bvid, super.key});

  final String bvid;

  @override
  State<QualityButtonV> createState() => _QualityButtonVState();
}

class _QualityButtonVState extends State<QualityButtonV> {
  Future<void> _changeQuality(int qn) async {
    final service = context.read<VideoPageVm>();
    final position = MediaS.i.currentPosition;
    await service.loadPlayUrl(widget.bvid, qn: qn);
    if (!mounted) return;
    final cid = service.getCid();
    if (service.playUrl == null || cid == null) return;
    await MediaS.i.initAndLoad(
      service.playUrl!,
      bvid: widget.bvid,
      cid: cid,
      startPosition: position,
    );
  }

  String _getQualityLabel(int qn, VideoPageVm service) {
    final desc = service.getQualityDesc(qn);
    if (desc?.isNotEmpty ?? false) return desc!;
    final videoQuality = VideoQualityM.values.firstWhere(
      (e) => e.qn == qn,
      orElse: () => VideoQualityM.a1080p30,
    );
    return videoQuality.qn == qn ? videoQuality.name : qn.toString();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<VideoPageVm>();
    final qualities = service.playUrl?.acceptQuality ?? [];
    if (qualities.isEmpty) return const SizedBox.shrink();

    final currentQn = service.currentQn;
    final currentLabel = currentQn != null
        ? _getQualityLabel(currentQn, service)
        : '画质';

    return PopupMenuButton<int>(
      tooltip: '画质',
      padding: EdgeInsets.zero,
      initialValue: currentQn,
      color: Colors.black.withValues(alpha: 0.8),
      itemBuilder: (context) {
        return qualities.map((qn) {
          return PopupMenuItem<int>(
            height: 35,
            padding: const EdgeInsets.only(left: 30),
            value: qn,
            onTap: () => _changeQuality(qn),
            child: Text(
              _getQualityLabel(qn, service),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          );
        }).toList();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          currentLabel,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }
}

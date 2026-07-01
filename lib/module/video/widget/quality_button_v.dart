import 'package:flutter/material.dart';
import 'package:flutter_bili/module/video/model/video_quality_m.dart';
import 'package:flutter_bili/module/video/video_page_vm.dart';

class QualityButtonV extends StatelessWidget {
  const QualityButtonV({required this.videoPageVm, super.key});

  final VideoPageVm videoPageVm;

  String _getQualityLabel(int qn, VideoPageVm vm) {
    final desc = vm.getQualityDesc(qn);
    if (desc?.isNotEmpty ?? false) return desc!;
    final videoQuality = VideoQualityM.values.firstWhere(
      (e) => e.qn == qn,
      orElse: () => VideoQualityM.a1080p30,
    );
    return videoQuality.qn == qn ? videoQuality.title : qn.toString();
  }

  @override
  Widget build(BuildContext context) {
    final qualities = videoPageVm.playUrl?.acceptQuality ?? [];
    if (qualities.isEmpty) return const SizedBox.shrink();

    final currentQn = videoPageVm.currentQn;
    final currentLabel = currentQn != null
        ? _getQualityLabel(currentQn, videoPageVm)
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
            onTap: () => videoPageVm.changeQuality(qn),
            child: Text(
              _getQualityLabel(qn, videoPageVm),
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

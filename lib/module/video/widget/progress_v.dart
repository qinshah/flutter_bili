import 'package:flutter/material.dart';
import 'package:flutter_bili/module/video/video_page_vm.dart';
import 'package:provider/provider.dart';

class ProgressV extends StatelessWidget {
  const ProgressV({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<VideoPageVm>();
    return StreamBuilder(
      stream: vm.durationStream,
      builder: (context, durSnap) {
        final dur = durSnap.data ?? vm.currentDuration;
        return StreamBuilder(
          stream: vm.positionStream,
          builder: (context, posSnap) {
            final pos = posSnap.data ?? vm.currentPosition;
            final value = pos.inMilliseconds / dur.inMilliseconds;
            final draggingValue = context.select<VideoPageVm, double?>(
              (vm) => vm.draggingProgress,
            );
            return Slider(
              padding: EdgeInsets.zero,
              value: (draggingValue ?? value).clamp(0, 1),
              onChanged: (_) {},
            );
          },
        );
      },
    );
  }
}

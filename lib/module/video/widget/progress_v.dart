import 'package:flutter/material.dart';
import 'package:flutter_bili/service/media_s.dart';
import 'package:provider/provider.dart';

class ProgressV extends StatelessWidget {
  const ProgressV({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: MediaS.i.durationStream,
      builder: (context, durSnap) {
        final dur = durSnap.data ?? MediaS.i.currentDuration;
        return StreamBuilder(
          stream: MediaS.i.positionStream,
          builder: (context, posSnap) {
            final pos = posSnap.data ?? MediaS.i.currentPosition;
            final value = pos.inMilliseconds / dur.inMilliseconds;
            final draggingValue = context.select<MediaS, double?>(
              (mediaS) => mediaS.draggingProgress,
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

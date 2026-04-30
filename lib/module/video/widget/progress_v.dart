import 'package:flutter/material.dart';
import 'package:flutter_bili/service/media_s.dart';
import 'package:provider/provider.dart';

class ProgressV extends StatelessWidget {
  const ProgressV({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: MediaS.i.durationStream,
      initialData: MediaS.i.currentDuration,
      builder: (context, durSnap) {
        final dur = durSnap.data ?? const Duration(days: 1);
        return StreamBuilder<Duration>(
          stream: MediaS.i.positionStream,
          initialData: MediaS.i.currentPosition,
          builder: (context, posSnap) {
            final pos = posSnap.data ?? Duration.zero;
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

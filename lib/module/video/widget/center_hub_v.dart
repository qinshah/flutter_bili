import 'package:flutter/material.dart';
import 'package:flutter_bili/module/video/video_page_vm.dart';

class CenterHubV extends StatelessWidget {
  const CenterHubV({super.key, required VideoPageVm vm}) : _vm = vm;

  final VideoPageVm _vm;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _vm.brightnessHubStream,
      builder: (context, asyncSnapshot) {
        double? brightnessHub = asyncSnapshot.data;
        return StreamBuilder(
          stream: _vm.volumeHubStream,
          builder: (context, asyncSnapshot) {
            double? volumeHub = asyncSnapshot.data;
            String? text = volumeHub == null
                ? null
                : '音量：${(volumeHub * 100).toInt()}%';
            if (text == null && brightnessHub != null) {
              text = '亮度：${(brightnessHub * 100).toInt()}%';
            }
            if (text == null) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          },
        );
      },
    );
  }
}

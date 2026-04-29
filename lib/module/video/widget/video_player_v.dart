import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../service/media_s.dart';

class VideoPlayerV extends StatefulWidget {
  const VideoPlayerV({
    this.onQualityTap,
    this.onFullscreen,
    this.isFullscreen = false,
    super.key,
  });

  final VoidCallback? onQualityTap;
  final VoidCallback? onFullscreen;
  final bool isFullscreen;

  @override
  State<VideoPlayerV> createState() => _VideoPlayerVState();
}

class _VideoPlayerVState extends State<VideoPlayerV> {
  bool _visible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _scheduleHide();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _visible = false);
    });
  }

  void _onTap() {
    setState(() => _visible = !_visible);
    if (_visible) _scheduleHide();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<MediaS>();
    return Stack(
      fit: StackFit.expand,
      children: [
        MediaS.i.buildVideoView(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onTap,
        ),
        if (_visible)
          _VideoHud(
            onQualityTap: widget.onQualityTap,
            onFullscreen: widget.onFullscreen,
            isFullscreen: widget.isFullscreen,
          ),
      ],
    );
  }
}

class _VideoHud extends StatelessWidget {
  const _VideoHud({
    required this.isFullscreen,
    this.onQualityTap,
    this.onFullscreen,
  });

  final VoidCallback? onQualityTap;
  final VoidCallback? onFullscreen;
  final bool isFullscreen;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomButton(context),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: MediaS.i.positionStream,
      initialData: MediaS.i.currentPosition,
      builder: (_, posSnap) {
        return Row(
          children: [
            StreamBuilder<bool>(
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
            Expanded(
              child: StreamBuilder<Duration>(
                stream: MediaS.i.durationStream,
                initialData: MediaS.i.currentDuration,
                builder: (_, durSnap) {
                  final pos = posSnap.data ?? Duration.zero;
                  final dur = durSnap.data ?? Duration.zero;
                  final max = dur.inMilliseconds.toDouble();
                  final val = pos.inMilliseconds.toDouble().clamp(
                    0.0,
                    max > 0 ? max : 1.0,
                  );
                  return Slider(
                    value: val,
                    max: max > 0 ? max : 1.0,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white38,
                    onChanged: max > 0
                        ? (v) =>
                              MediaS.i.seek(Duration(milliseconds: v.toInt()))
                        : null,
                  );
                },
              ),
            ),
            if (onQualityTap != null)
              TextButton(
                onPressed: onQualityTap,
                child: const Text(
                  '画质',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            if (onFullscreen != null)
              IconButton(
                icon: Icon(
                  isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                ),
                onPressed: onFullscreen,
              ),
          ],
        );
      },
    );
  }
}

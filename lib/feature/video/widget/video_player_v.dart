import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../service/media_s.dart';
import '../model/play_url_model.dart';

class VideoPlayerV extends StatefulWidget {
  const VideoPlayerV({
    this.playUrl,
    this.onQualityTap,
    this.onFullscreen,
    this.isFullscreen = false,
    super.key,
  });

  final PlayUrlModel? playUrl;
  final VoidCallback? onQualityTap;
  final VoidCallback? onFullscreen;
  final bool isFullscreen;

  @override
  State<VideoPlayerV> createState() => _VideoPlayerVState();
}

class _VideoPlayerVState extends State<VideoPlayerV> {
  @override
  Widget build(BuildContext context) {
    context.watch<MediaS>();
    return Stack(
      fit: StackFit.expand,
      children: [
        MediaS.i.buildVideoWidget(),
        _VideoHud(
          playUrl: widget.playUrl,
          onQualityTap: widget.onQualityTap,
          onFullscreen: widget.onFullscreen,
          isFullscreen: widget.isFullscreen,
        ),
      ],
    );
  }
}

class _VideoHud extends StatefulWidget {
  const _VideoHud({
    this.playUrl,
    this.onQualityTap,
    this.onFullscreen,
    required this.isFullscreen,
  });

  final PlayUrlModel? playUrl;
  final VoidCallback? onQualityTap;
  final VoidCallback? onFullscreen;
  final bool isFullscreen;

  @override
  State<_VideoHud> createState() => _VideoHudState();
}

class _VideoHudState extends State<_VideoHud> {
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black54],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _ProgressBar(),
              Row(
                children: [
                  StreamBuilder<bool>(
                    stream: MediaS.i.playingStream,
                    initialData: MediaS.i.isPlaying,
                    builder: (_, snap) => IconButton(
                      icon: Icon(
                        snap.data == true ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () => MediaS.i.playOrPause(),
                    ),
                  ),
                  const Spacer(),
                  if (widget.onQualityTap != null)
                    TextButton(
                      onPressed: widget.onQualityTap,
                      child: const Text(
                        '画质',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  if (widget.onFullscreen != null)
                    IconButton(
                      icon: Icon(
                        widget.isFullscreen
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                        color: Colors.white,
                      ),
                      onPressed: widget.onFullscreen,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: MediaS.i.positionStream,
      initialData: MediaS.i.currentPosition,
      builder: (_, posSnap) {
        return StreamBuilder<Duration>(
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
              min: 0,
              max: max > 0 ? max : 1.0,
              activeColor: Colors.white,
              inactiveColor: Colors.white38,
              onChanged: max > 0
                  ? (v) => MediaS.i.seek(Duration(milliseconds: v.toInt()))
                  : null,
            );
          },
        );
      },
    );
  }
}

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';

import '../../core/http/loading_state.dart';
import '../../core/http/video_http.dart';
import 'model/play_url_model.dart';
import 'model/related_video.dart';
import 'model/video_detail.dart';
import 'video_page_vm.dart';

// ─── Error code mapping ───────────────────────────────────────────────────────

String mapErrorCode(int? code, String? message) {
  switch (code) {
    case -404:
      return '视频不存在或已被删除';
    case 87008:
      return '该视频为专属视频，可能需要充电观看';
    default:
      return message ?? '加载失败';
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class VideoDetailPage extends StatefulWidget {
  const VideoDetailPage({super.key, required this.bvid});

  final String bvid;

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late final Player _player;
  late final VideoController _controller;
  Timer? _heartbeatTimer;
  int _currentCid = 0;
  
  // 相关推荐视频
  List<RelatedVideoItem> _relatedVideos = [];
  bool _loadingRelated = false;

  @override
  void initState() {
    super.initState();
    _player = Player(
      configuration: const PlayerConfiguration(
        bufferSize: 32 * 1024 * 1024, // 32MB buffer
      ),
    );
    _controller = VideoController(_player);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetail());
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  // ── Data loading ────────────────────────────────────────────────────────────

  Future<void> _loadDetail() async {
    final service = context.read<VideoPageVm>();
    await service.loadDetail(widget.bvid);
    if (!mounted) return;
    final detail = service.detail;
    if (detail != null && detail.pages.isNotEmpty) {
      _currentCid = detail.pages[0].cid;
      await service.loadPlayUrl(widget.bvid, _currentCid);
      if (!mounted) return;
      _loadMedia(service.playUrl);
      // 加载相关推荐
      _loadRelatedVideos();
    }
  }

  /// 加载相关推荐视频
  Future<void> _loadRelatedVideos() async {
    setState(() => _loadingRelated = true);
    final result = await VideoHttp.relatedVideoList(bvid: widget.bvid);
    if (!mounted) return;
    
    if (result is Success<List<RelatedVideoItem>>) {
      setState(() {
        _relatedVideos = result.response;
        _loadingRelated = false;
      });
    } else {
      setState(() => _loadingRelated = false);
    }
  }

  Future<void> _loadMedia(PlayUrlModel? playUrl) async {
    if (playUrl == null) return;
    
    final videoUrl = playUrl.dash?.video?.first.baseUrl;
    final audioUrl = playUrl.dash?.audio?.first.baseUrl;
    
    if (videoUrl == null || videoUrl.isEmpty) return;

    // B站的DASH视频需要分别加载视频和音频流
    final headers = {
      'referer': 'https://www.bilibili.com',
      'user-agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
    };

    try {
      // 获取NativePlayer实例并设置音频
      if (audioUrl != null && audioUrl.isNotEmpty) {
        final nativePlayer = _player.platform as NativePlayer?;
        if (nativePlayer != null) {
          // 等待播放器初始化
          await nativePlayer.waitForPlayerInitialization;
          
          // 设置音频轨道（参考PiliPlus）
          await _player.setAudioTrack(AudioTrack.auto());
          
          // 处理URL中的特殊字符
          final processedAudioUrl = audioUrl.replaceAll(':', '\\:');
          
          // 设置音频文件
          await nativePlayer.setProperty('audio-files', processedAudioUrl);
          debugPrint('音频URL已设置: $processedAudioUrl');
        }
      }

      // 加载视频（带请求头）
      await _player.open(
        Media(videoUrl, httpHeaders: headers),
        play: true,
      );
      
      _startHeartbeat();
    } catch (e) {
      debugPrint('加载媒体失败: $e');
    }
  }

  // ── Heartbeat ───────────────────────────────────────────────────────────────

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      VideoHttp.heartBeat(
        bvid: widget.bvid,
        cid: _currentCid,
        progress: _player.state.position.inSeconds,
      );
    });
  }

  // ── Page switching ──────────────────────────────────────────────────────────

  void _switchPage(int index) {
    final service = context.read<VideoPageVm>();
    final detail = service.detail;
    if (detail == null || index < 0 || index >= detail.pages.length) return;
    _currentCid = detail.pages[index].cid;
    service.selectPage(index);
    // Wait for playUrl to update then reload media
    Future.microtask(() async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      _loadMedia(context.read<VideoPageVm>().playUrl);
    });
  }

  // ── Quality switching ───────────────────────────────────────────────────────

  void _showQualityPicker(PlayUrlModel playUrl) {
    final service = context.read<VideoPageVm>();
    final qualities = playUrl.acceptQuality ?? [];
    if (qualities.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: qualities.map((qn) {
          final label = _qualityLabel(qn);
          return ListTile(
            title: Text(label),
            onTap: () async {
              Navigator.pop(ctx);
              await service.loadPlayUrl(widget.bvid, _currentCid, qn: qn);
              if (!mounted) return;
              _loadMedia(service.playUrl);
            },
          );
        }).toList(),
      ),
    );
  }

  String _qualityLabel(int qn) {
    const map = {
      116: '1080P60',
      80: '1080P',
      64: '720P',
      32: '480P',
      16: '360P',
    };
    return map[qn] ?? qn.toString();
  }

  // ── Widgets ─────────────────────────────────────────────────────────────────

  Widget _buildPlayer(PlayUrlModel? playUrl) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          Video(controller: _controller),
          // Controls overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _PlayerControls(
              player: _player,
              playUrl: playUrl,
              onQualityTap: playUrl != null ? () => _showQualityPicker(playUrl) : null,
              onFullscreen: () => _pushFullscreen(),
            ),
          ),
        ],
      ),
    );
  }

  void _pushFullscreen() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => _FullscreenPlayer(controller: _controller, player: _player),
      ),
    );
  }

  Widget _buildOwnerRow(VideoDetailData detail) {
    return Row(
      children: [
        ClipOval(
          child: CachedNetworkImage(
            imageUrl: detail.owner.face,
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => const Icon(Icons.person, size: 36),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            detail.owner.name,
            style: const TextStyle(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(StatInfo stat) {
    return Row(
      children: [
        const Icon(Icons.play_arrow, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(_formatCount(stat.view), style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(width: 16),
        const Icon(Icons.thumb_up_outlined, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(_formatCount(stat.like), style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  String _formatCount(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}万';
    return n.toString();
  }

  Widget _buildVideoInfo(VideoDetailData detail) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          _buildStatRow(detail.stat),
          const SizedBox(height: 12),
          _buildOwnerRow(detail),
          if (detail.desc.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              detail.desc,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (detail.pages.length > 1) ...[
            const SizedBox(height: 12),
            _buildPagesList(detail),
          ],
        ],
      ),
    );
  }

  Widget _buildPagesList(VideoDetailData detail) {
    final service = context.watch<VideoPageVm>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('选集', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: detail.pages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final selected = service.selectedPage == i;
              return GestureDetector(
                onTap: () => _switchPage(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? Theme.of(context).colorScheme.primary : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'P${detail.pages[i].page}',
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message, {required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('视频详情')),
      body: Consumer<VideoPageVm>(
        builder: (context, service, _) {
          // Detail loading state
          if (service.detailState == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (service.detailState is Error) {
            final err = service.detailState as Error;
            // Try to parse error code from message
            final msg = mapErrorCode(null, err.message);
            return _buildErrorState(msg, onRetry: _loadDetail);
          }

          final detail = service.detail!;
          final playUrl = service.playUrl;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 800;
              if (isWide) {
                return _buildWideLayout(detail, playUrl, service);
              } else {
                return _buildNarrowLayout(detail, playUrl, service);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildNarrowLayout(VideoDetailData detail, PlayUrlModel? playUrl, VideoPageVm service) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlayer(playUrl),
          _buildPlayUrlError(service),
          _buildVideoInfo(detail),
          const Divider(height: 1),
          _buildTabSection(detail),
        ],
      ),
    );
  }

  Widget _buildWideLayout(VideoDetailData detail, PlayUrlModel? playUrl, VideoPageVm service) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: player + info + tabs
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlayer(playUrl),
                _buildPlayUrlError(service),
                _buildVideoInfo(detail),
                const Divider(height: 1),
                _buildTabSection(detail),
              ],
            ),
          ),
        ),
        // Right: related videos
        Expanded(
          flex: 1,
          child: _buildRelatedVideosPanel(),
        ),
      ],
    );
  }

  /// Tab区域（简介和评论）
  Widget _buildTabSection(VideoDetailData detail) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: '简介'),
              Tab(text: '评论'),
            ],
          ),
          SizedBox(
            height: 400,
            child: TabBarView(
              children: [
                _buildIntroTab(detail),
                _buildReplyTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 简介Tab
  Widget _buildIntroTab(VideoDetailData detail) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (detail.desc.isNotEmpty) ...[
          Text(
            detail.desc,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
        ],
        // 相关推荐（窄屏时显示）
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 800) {
              return const SizedBox.shrink();
            }
            return _buildRelatedVideosSection();
          },
        ),
      ],
    );
  }

  /// 评论Tab
  Widget _buildReplyTab() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '评论区功能待实现',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// 相关推荐视频区域（窄屏）
  Widget _buildRelatedVideosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '相关推荐',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (_loadingRelated)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else
          ..._relatedVideos.map((video) => _buildRelatedVideoCard(video)),
      ],
    );
  }

  /// 相关推荐视频面板（宽屏）
  Widget _buildRelatedVideosPanel() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '相关推荐',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _loadingRelated
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _relatedVideos.length,
                    itemBuilder: (context, index) {
                      return _buildRelatedVideoCard(_relatedVideos[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// 相关推荐视频卡片
  Widget _buildRelatedVideoCard(RelatedVideoItem video) {
    return InkWell(
      onTap: () {
        if (video.bvid != null) {
          // 跳转到新的视频详情页
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => VideoDetailPage(bvid: video.bvid!),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: video.pic != null
                  ? CachedNetworkImage(
                      imageUrl: video.pic!,
                      width: 160,
                      height: 90,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 160,
                        height: 90,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    )
                  : Container(
                      width: 160,
                      height: 90,
                      color: Colors.grey[300],
                    ),
            ),
            const SizedBox(width: 12),
            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (video.owner?.name != null)
                    Text(
                      video.owner!.name!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatCount(video.stat?.view ?? 0),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayUrlError(VideoPageVm service) {
    if (service.playUrlState is Error) {
      final err = service.playUrlState as Error;
      final msg = mapErrorCode(null, err.message);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.orange, size: 18),
            const SizedBox(width: 6),
            Expanded(child: Text(msg, style: const TextStyle(color: Colors.orange, fontSize: 13))),
            TextButton(
              onPressed: () {
                final detail = service.detail;
                if (detail != null) {
                  service.loadPlayUrl(widget.bvid, _currentCid);
                }
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

// ─── Player controls overlay ──────────────────────────────────────────────────

class _PlayerControls extends StatefulWidget {
  const _PlayerControls({
    required this.player,
    required this.playUrl,
    required this.onQualityTap,
    required this.onFullscreen,
  });

  final Player player;
  final PlayUrlModel? playUrl;
  final VoidCallback? onQualityTap;
  final VoidCallback onFullscreen;

  @override
  State<_PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<_PlayerControls> {
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
              _ProgressBar(player: widget.player),
              Row(
                children: [
                  StreamBuilder<bool>(
                    stream: widget.player.stream.playing,
                    initialData: widget.player.state.playing,
                    builder: (_, snap) => IconButton(
                      icon: Icon(
                        snap.data == true ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () => widget.player.playOrPause(),
                    ),
                  ),
                  const Spacer(),
                  if (widget.onQualityTap != null)
                    TextButton(
                      onPressed: widget.onQualityTap,
                      child: const Text('画质', style: TextStyle(color: Colors.white)),
                    ),
                  IconButton(
                    icon: const Icon(Icons.fullscreen, color: Colors.white),
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

// ─── Progress bar ─────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.stream.position,
      initialData: player.state.position,
      builder: (_, posSnap) {
        return StreamBuilder<Duration>(
          stream: player.stream.duration,
          initialData: player.state.duration,
          builder: (_, durSnap) {
            final pos = posSnap.data ?? Duration.zero;
            final dur = durSnap.data ?? Duration.zero;
            final max = dur.inMilliseconds.toDouble();
            final val = pos.inMilliseconds.toDouble().clamp(0.0, max > 0 ? max : 1.0);
            return Slider(
              value: val,
              min: 0,
              max: max > 0 ? max : 1.0,
              activeColor: Colors.white,
              inactiveColor: Colors.white38,
              onChanged: max > 0
                  ? (v) => player.seek(Duration(milliseconds: v.toInt()))
                  : null,
            );
          },
        );
      },
    );
  }
}

// ─── Fullscreen player ────────────────────────────────────────────────────────

class _FullscreenPlayer extends StatelessWidget {
  const _FullscreenPlayer({required this.controller, required this.player});

  final VideoController controller;
  final Player player;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: Video(controller: controller)),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

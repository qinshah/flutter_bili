import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bili/core/routes.dart';
import 'package:flutter_bili/module/video/model/video_quality_m.dart';
import 'package:flutter_bili/module/video/widget/progress_v.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:u_widget/u_widget.dart';

import '../../core/http/loading_state.dart';
import '../../core/http/video_http.dart';
import '../../service/media_s.dart';
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

class VideoPageV extends StatefulWidget {
  const VideoPageV({required this.bvid, super.key});

  final String bvid;

  @override
  State<VideoPageV> createState() => _VideoPageVState();
}

class _VideoPageVState extends State<VideoPageV> {
  int _currentCid = 0;

  // 相关推荐视频
  List<RelatedVideoItem> _relatedVideos = [];
  bool _loadingRelated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetail());
  }

  @override
  void dispose() {
    MediaS.i.disposePlayer();
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
      if (service.playUrl != null) {
        MediaS.i.initAndLoad(
          service.playUrl!,
          bvid: widget.bvid,
          cid: _currentCid,
        );
      }
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
      final playUrl = context.read<VideoPageVm>().playUrl;
      if (playUrl != null) {
        MediaS.i.initAndLoad(playUrl, bvid: widget.bvid, cid: _currentCid);
      }
    });
  }

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

  // ── Widgets ─────────────────────────────────────────────────────────────────

  Widget _buildPlayer() {
    return UVideoPlayer(
      onProgressTapDown: MediaS.i.seekByProgress,
      onTogglePlay: MediaS.i.playOrPause,
      onDoubleTapDown: (details) => details.kind == PointerDeviceKind.mouse
          ? _fullscreen()
          : MediaS.i.playOrPause(),
      video: MediaS.i.buildVideoView(),
      topLeft: (_) => const BackButton(),
      bottomLeft: (_) => StreamBuilder<bool>(
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
      topRight: (_) => const Row(
        children: [Icon(Icons.info), Icon(Icons.more_vert)],
      ),
      topCenter: (_) => const Center(child: Text('标题')),
      progressBuilder: (context) => const ProgressV(),
      centerLeft: (_) => const Icon(Icons.lock),
      centerRight: (_) => const Icon(Icons.camera),
      onProgressDragEnd: MediaS.i.onProgressDragEnd,
      onProgressDragUpdate: MediaS.i.onProgressDragUpdate,
      bottomRight: (_) => Row(
        children: [
          IconButton(
            onPressed: _fullscreen,
            icon: const Icon(Icons.fullscreen),
          ),
        ],
      ),
    );
  }

  Future<void> _fullscreen() async {
    await context.push(
      Routes.fullscreenVideo,
      extra: widget.bvid,
    );
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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
        Text(
          _formatCount(stat.view),
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(width: 16),
        const Icon(Icons.thumb_up_outlined, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          _formatCount(stat.like),
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
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
        const Text(
          '选集',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade200,
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
      appBar: AppBar(toolbarHeight: 0),
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

  Widget _buildNarrowLayout(
    VideoDetailData detail,
    PlayUrlModel? playUrl,
    VideoPageVm service,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlayer(),
          _buildPlayUrlError(service),
          _buildVideoInfo(detail),
          const Divider(height: 1),
          _buildTabSection(detail),
        ],
      ),
    );
  }

  Widget _buildWideLayout(
    VideoDetailData detail,
    PlayUrlModel? playUrl,
    VideoPageVm service,
  ) {
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
                _buildPlayer(),
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
      onTap: () async {
        if (video.bvid != null) {
          // 跳转到新的视频详情页
          await context.push(
            Routes.video,
            extra: video.bvid,
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
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(color: Colors.orange, fontSize: 13),
              ),
            ),
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

import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bili/module/video/video_page_vm.dart';
import 'package:flutter_bili/module/video/widget/center_hub_v.dart';
import 'package:flutter_bili/module/video/widget/progress_v.dart';
import 'package:flutter_bili/module/video/widget/quality_button_v.dart';
import 'package:flutter_bili/route/global_r_o.dart';
import 'package:flutter_bili/route/my_route.dart';
import 'package:flutter_bili/route/router.dart';
import 'package:flutter_floating/flutter_floating.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:u_service/u_service.dart';
import 'package:u_widget/u_widget.dart';

import '../../core/http/loading_state.dart';
import '../../core/http/video_http.dart';
import 'model/play_url_model.dart';
import 'model/related_video.dart';
import 'model/video_detail.dart';

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
  const VideoPageV({super.key});

  @override
  State<VideoPageV> createState() => _VideoPageVState();
}

class _VideoPageVState extends State<VideoPageV> with MyRouteAware, TickerProviderStateMixin {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) RO.subscribe(this, route);
  }

  @override
  void didPush() => floatingManager.disposeAllFloating();

  @override
  void didPopNext(nextRoute) => _vm.onPopNext(nextRoute.settings.name);
  @override
  void didPushNext(nextRoute) =>
      _vm.didPushNext(nextRoute.settings.name, context);
  @override
  void didPop(previousRoute) =>
      _vm.didPop(previousRoute.settings.name, context);
  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _nestedScrollController.removeListener(_onScrollChanged);
    _nestedScrollController.dispose();
    RO.unsubscribe(this);
    super.dispose();
  }

  late final VideoPageVm _vm = context.read<VideoPageVm>();

  // Tab and scroll state
  late final TabController _tabController;
  final ScrollController _nestedScrollController = ScrollController();
  bool _isCollapsed = false;

  // 相关推荐视频
  List<RelatedVideoItem> _relatedVideos = [];
  bool _loadingRelated = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _nestedScrollController.addListener(_onScrollChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _vm.switchTab(_tabController.index);
    }
  }

  void _onScrollChanged() {
    final collapsed = _nestedScrollController.hasClients &&
        _nestedScrollController.offset > 50;
    if (collapsed != _isCollapsed) {
      setState(() => _isCollapsed = collapsed);
    }
  }

  Future<void> _init() async {
    _vm.initUIStream();
    await _vm.loadDetail();
    if (!mounted) return;
    await _vm.loadPlayUrl();
    if (!mounted) return;
    await Future.wait([_vm.initPlayer(), _loadRelatedVideos()]);
  }

  /// 加载相关推荐视频
  Future<void> _loadRelatedVideos() async {
    setState(() => _loadingRelated = true);
    final result = await VideoHttp.relatedVideoList(bvid: _vm.bvid);
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

  Future<void> _switchPage(int index) async {
    _vm.selectPage(index);
    await _vm.loadPlayUrl();
    if (!mounted) return;
    await _vm.initPlayer();
  }

  Widget _buildPlayer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        return UVideoPlayer(
          aspectRatio: _vm.getAspectRatio(),
          onProgressTapDown: _vm.seekByProgress,
          onTogglePlay: _vm.playOrPause,
          onVerticalDragUpdate: (details) =>
              _vm.onVerticalDragUpdate(details, maxWidth),
          onVerticalDragStart: _vm.onVerticalDragStart,
          onVerticalDragEnd: _vm.onVerticalDragEnd,
          onDoubleTapDown: (details) => details.kind == PointerDeviceKind.mouse
              ? _fullScreen()
              : _vm.playOrPause(),
          video: _vm.buildVideoView(),
          topLeft: (_) => const BackButton(color: Colors.white),
          bottomRight: (_) => Row(
            children: [
              Builder(builder: (context) => QualityButtonV(videoPageVm: _vm)),
              IconButton(
                onPressed: _fullScreen,
                icon: const Icon(Icons.fullscreen, color: Colors.white),
              ),
            ],
          ),
          bottomLeft: (_) => StreamBuilder<bool>(
            stream: _vm.playingStream,
            initialData: _vm.isPlaying,
            builder: (_, snap) => IconButton(
              icon: Icon(
                snap.data ?? false ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: _vm.playOrPause,
            ),
          ),
          topRight: (_) => Row(
            children: [
              IconButton(
                onPressed: () async {
                  final jsonInfo = (await _vm.getPlayingInfo()).toJson();
                  if (!mounted) return;
                  await showDialog<void>(
                    context: context,
                    builder: (ctx) => SimpleDialog(
                      title: const Text('播放信息'),
                      children: [
                        for (final entry in jsonInfo.entries)
                          ListTile(
                            title: Text(entry.key),
                            subtitle: Text(entry.value.toString()),
                          ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.info, color: Colors.white),
              ),
              const Icon(Icons.more_vert, color: Colors.white),
            ],
          ),
          topCenter: (_) => const Center(child: Text('标题')),
          progressBuilder: (context) => const ProgressV(),
          centerLeft: (_) => const Icon(Icons.lock),
          centerRight: (_) => const Icon(Icons.camera),
          center: (context, progress) => CenterHubV(vm: _vm),
          onProgressDragEnd: _vm.onProgressDragEnd,
          onProgressDragUpdate: _vm.onProgressDragUpdate,
        );
      },
    );
  }

  // ── Collapsible video space for SliverAppBar ──────────────────────────────

  Widget _buildFlexibleVideoSpace(double expandedHeight, VideoDetailData detail) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCollapsed =
            constraints.maxHeight <= kToolbarHeight + 20;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Video player (hidden when collapsed to save resources)
            if (!isCollapsed)
              _buildPlayer()
            else
              Container(color: Colors.black),

            // Play button overlay when collapsed and paused
            if (isCollapsed && !_vm.isPlaying)
              GestureDetector(
                onTap: _expandAndPlay,
                child: Container(
                  color: Colors.black87,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),

            // Collapsed title
            if (isCollapsed)
              Positioned(
                top: MediaQuery.of(context).padding.top,
                left: 52,
                right: 8,
                height: kToolbarHeight,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    detail.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _expandAndPlay() {
    _vm.playOrPause();
    _nestedScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _fullScreen() async {
    await Future.wait([
      USystemS.fullScreen(landscape: _vm.isVideoLandscape()),
      context.push(Routes.fullscreenVideo, extra: _vm),
    ]);
    await USystemS.exitFullScreen();
  }

  Widget _buildOwnerRow(VideoDetailData detail) {
    return InkWell(
      onTap: () {
        context.push(Routes.up, extra: detail.owner.mid.toString());
      },
      child: Row(
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: detail.owner.face,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => const Icon(Icons.person, size: 36),
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
      ),
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

  // String _formatDuration(Duration d) {
  //   final hours = d.inHours;
  //   final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  //   final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  //   if (hours > 0) {
  //     return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
  //   }
  //   return '$minutes:$seconds';
  // }

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
      body: Builder(
        builder: (context) {
          final vm = context.watch<VideoPageVm>();
          // Detail loading state
          if (vm.detailState == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.detailState is Error) {
            final err = vm.detailState! as Error;
            // Try to parse error code from message
            final msg = mapErrorCode(null, err.message);
            return _buildErrorState(msg, onRetry: _init);
          }

          final detail = vm.detail!;
          final playUrl = vm.playUrl;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 800;
              if (isWide) {
                return _buildWideLayout(detail, playUrl);
              } else {
                return _buildNarrowLayout(detail);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildNarrowLayout(VideoDetailData detail) {
    final videoHeight = MediaQuery.of(context).size.width / _vm.getAspectRatio();

    // Sync VM tab index -> TabController
    if (_tabController.index != _vm.currentTabIndex &&
        !_tabController.indexIsChanging) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _tabController.animateTo(_vm.currentTabIndex);
      });
    }

    return NestedScrollView(
      controller: _nestedScrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: videoHeight,
            collapsedHeight: kToolbarHeight,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: _buildFlexibleVideoSpace(videoHeight, detail),
          ),
          SliverToBoxAdapter(child: _buildPlayUrlError()),
          SliverToBoxAdapter(child: _buildVideoInfo(detail)),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabDelegate(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: '简介'),
                    Tab(text: '评论'),
                  ],
                ),
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildIntroTabContent(detail),
          _buildReplyTabContent(),
        ],
      ),
    );
  }

  Widget _buildWideLayout(VideoDetailData detail, PlayUrlModel? playUrl) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: player + info + tabs (reuse nested scroll layout)
        Expanded(
          flex: 3,
          child: _buildNarrowLayout(detail),
        ),
        // Right: related videos
        Expanded(flex: 1, child: _buildRelatedVideosPanel()),
      ],
    );
  }

  /// 简介 Tab 内容
  Widget _buildIntroTabContent(VideoDetailData detail) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (detail.desc.isNotEmpty) ...[
          Text(detail.desc, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
        ],
        if (detail.pages.length > 1) ...[
          _buildPagesList(detail),
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

  /// 评论 Tab 内容
  Widget _buildReplyTabContent() {
    return ListView(
      children: [
        const SizedBox(height: 200),
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text('评论区功能待实现', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        if (video.bvid == null) return;
        if (!mounted) return;
        context.push(Routes.video, extra: video.bvid);
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
                  : Container(width: 160, height: 90, color: Colors.grey[300]),
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

  Widget _buildPlayUrlError() {
    if (_vm.playUrlState is Error) {
      final err = _vm.playUrlState! as Error;
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
              onPressed: () => _vm.loadPlayUrl(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

// ── SliverPersistentHeaderDelegate for the tab bar ───────────────────────────

class _SliverTabDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabDelegate({required this.child});

  final Widget child;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(_SliverTabDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}

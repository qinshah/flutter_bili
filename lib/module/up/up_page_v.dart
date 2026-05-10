import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bili/core/http/loading_state.dart';
import 'package:flutter_bili/core/routes.dart';
import 'package:flutter_bili/module/up/model/space_archive.dart';
import 'package:flutter_bili/module/up/model/space_data.dart';
import 'package:flutter_bili/module/up/up_page_vm.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UpPageV extends StatefulWidget {
  const UpPageV({super.key});

  @override
  State<UpPageV> createState() => _UpPageVState();
}

class _UpPageVState extends State<UpPageV> {
  late final UpPageVm _vm = context.read<UpPageVm>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    await _vm.loadUserCard();
    if (!mounted) return;
    await _vm.loadArchives(refresh: true);
  }

  String _formatCount(int? n) {
    if (n == null) return '0';
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}万';
    return n.toString();
  }

  String _formatDuration(int? seconds) {
    if (seconds == null || seconds <= 0) return '';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  String _formatTime(int? timestamp) {
    if (timestamp == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays > 365) {
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } else if (diff.inDays > 30) {
      return '${diff.inDays ~/ 30}个月前';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}天前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UpPageVm>(
        builder: (context, vm, _) {
          final cardState = vm.cardState;

          if (cardState == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cardState case Error(:final message)) {
            return _buildErrorState(message ?? '加载失败');
          }

          final card = vm.card;
          if (card == null) {
            return _buildErrorState('加载失败');
          }

          return DefaultTabController(
            length: 1,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(child: _buildHeader(card)),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(
                      TabBar(
                        labelColor: Theme.of(context).colorScheme.primary,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Theme.of(context).colorScheme.primary,
                        tabs: const [
                          Tab(text: '投稿'),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: _buildContributeTab(vm),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(SpaceCard card) {
    return Column(
      children: [
        // 背景占位
        Container(height: 120, color: Colors.grey[200]),
        // 用户信息区
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 头像
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: card.face ?? '',
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 72,
                    height: 72,
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, size: 36),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 统计数据
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(_formatCount(card.fans), '粉丝'),
                    _buildStatItem(_formatCount(card.attention), '关注'),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 名称和简介
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    card.name ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (card.vip?.status == 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFB7299),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        card.vip?.label ?? '大会员',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
              if (card.sign != null && card.sign!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  card.sign!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              // 关注按钮
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFB7299),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('+ 关注'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
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
              onPressed: _init,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributeTab(UpPageVm vm) {
    final state = vm.archiveState;

    if (state == null && vm.archives.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state case Error(:final message) when vm.archives.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message ?? '加载失败'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => vm.loadArchives(refresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => vm.loadArchives(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: vm.archives.length + (vm.loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= vm.archives.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _buildVideoCard(vm.archives[index]);
        },
      ),
    );
  }

  Widget _buildVideoCard(SpaceArchiveItem video) {
    return InkWell(
      onTap: () {
        if (video.bvid != null && video.bvid!.isNotEmpty) {
          context.push(Routes.video, extra: video.bvid);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: video.cover ?? '',
                    width: 160,
                    height: 90,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 160,
                      height: 90,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                  // 时长
                  if (video.duration != null && video.duration! > 0)
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          _formatDuration(video.duration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                ],
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
                  if (video.author != null)
                    Text(
                      video.author!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        video.viewContent ?? _formatCount(video.play),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatCount(video.danmaku),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    video.publishTimeText ?? _formatTime(video.ctime),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar;
  }
}

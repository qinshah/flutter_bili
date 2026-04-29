import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bili/core/routes.dart';
import 'package:flutter_bili/module/dynamic/dynamic_page_vm.dart';
import 'package:flutter_bili/module/dynamic/model/dynamics_item.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// 动态页面
class DynamicPageV extends StatefulWidget {
  const DynamicPageV({super.key});

  @override
  State<DynamicPageV> createState() => _DynamicPageVState();
}

class _DynamicPageVState extends State<DynamicPageV>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late final TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
    
    // 首次加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = context.read<DynamicPageVm>();
      if (!service.hasData && !service.loading) {
        service.loadDynamics();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final service = context.read<DynamicPageVm>();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!service.loading && service.hasMore) {
        service.loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          tabs: const [
            Tab(text: '视频'),
            Tab(text: '综合'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: 发布动态
            },
            tooltip: '发布动态',
          ),
        ],
      ),
      body: Column(
        children: [
          // 最常访问UP主
          _buildFrequentUps(theme),
          const Divider(height: 1),
          // Tab内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _DynamicVideoTab(scrollController: _scrollController),
                const _DynamicAllTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 最常访问UP主
  Widget _buildFrequentUps(ThemeData theme) {
    return SizedBox(
      height: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '最常访问',
                style: theme.textTheme.titleSmall,
              ),
              TextButton(
                onPressed: () {},
                child: const Text('更多'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: const Icon(Icons.person, size: 20),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'UP主',
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 视频动态Tab
class _DynamicVideoTab extends StatelessWidget {
  final ScrollController scrollController;
  
  const _DynamicVideoTab({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Consumer<DynamicPageVm>(
      builder: (context, service, _) {
        // 初始加载中
        if (!service.hasData && service.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        // 加载失败
        if (!service.hasData && service.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(service.error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => service.refresh(),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        // 显示动态列表
        return RefreshIndicator(
          onRefresh: () => service.refresh(),
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(8),
            itemCount: service.videoList.length + (service.loading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= service.videoList.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return _buildDynamicCard(context, service.videoList[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildDynamicCard(BuildContext context, DynamicsItem item) {
    final theme = Theme.of(context);
    final author = item.modules?.moduleAuthor;
    final dynamic = item.modules?.moduleDynamic;
    final stat = item.modules?.moduleStat;
    final archive = dynamic?.major?.archive;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // 跳转视频详情
          if (archive?.bvid != null) {
            context.push(Routes.video, extra: archive!.bvid!);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // UP主信息
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: author?.face != null
                        ? CachedNetworkImageProvider(author!.face!)
                        : null,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: author?.face == null
                        ? const Icon(Icons.person, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          author?.name ?? 'UP主',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (author?.pubTime != null)
                          Text(
                            author!.pubTime!,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // 动态内容
              if (dynamic?.desc?.text != null) ...[
                Text(
                  dynamic!.desc!.text!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],
              
              // 视频封面
              if (archive != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: archive.cover != null
                            ? CachedNetworkImage(
                                imageUrl: archive.cover!,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  child: const Center(
                                    child: Icon(Icons.error),
                                  ),
                                ),
                              )
                            : Container(
                                color: theme.colorScheme.surfaceContainerHighest,
                              ),
                      ),
                      // 时长
                      if (archive.durationText != null)
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              archive.durationText!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      // 播放量
                      if (archive.stat?.play != null)
                        Positioned(
                          left: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  archive.stat!.play!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (archive.title != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    archive.title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
              ],
              
              // 互动按钮
              Row(
                children: [
                  _buildActionButton(
                    Icons.share_outlined,
                    stat?.forward?.count?.toString() ?? '转发',
                  ),
                  const SizedBox(width: 24),
                  _buildActionButton(
                    Icons.chat_bubble_outline,
                    stat?.comment?.count?.toString() ?? '评论',
                  ),
                  const SizedBox(width: 24),
                  _buildActionButton(
                    Icons.thumb_up_outlined,
                    stat?.like?.count?.toString() ?? '点赞',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

/// 综合动态Tab
class _DynamicAllTab extends StatelessWidget {
  const _DynamicAllTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('综合动态 - 待实现'),
    );
  }
}

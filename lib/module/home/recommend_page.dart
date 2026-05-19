import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bili/route/router.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'recommend_vm.dart';
import '../video/model/rec_video_item.dart';

class RecommendPage extends StatefulWidget {
  const RecommendPage({super.key});

  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // 首次加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = context.read<RecommendVm>();
      if (!service.hasData && !service.loading) {
        service.loadVideos();
      }
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  String _formatCount(int? count) {
    if (count == null) return '0';
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用以保持状态

    return Consumer<RecommendVm>(
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

        // 显示视频列表
        return RefreshIndicator(
          onRefresh: () => service.refresh(),
          child: GridView.builder(
            key: service.gridKey,
            controller: service.scrollController,
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,
              childAspectRatio: 0.8,
              crossAxisSpacing: 5,
              mainAxisSpacing: 6,
            ),
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
              final video = service.videoList[index];
              return _buildVideoCard(video);
            },
          ),
        );
      },
    );
  }

  Widget _buildVideoCard(RecVideoItem video) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: InkWell(
        onTap: () {
          if (video.bvid != null) {
            context.push(Routes.video, extra: video.bvid!);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: video.cover ?? '',
                    fit: BoxFit.cover,
                    memCacheWidth: 500,
                    errorWidget: (_, _, _) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                  // 播放量和点赞
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black45, Colors.transparent],
                        ),
                      ),
                      child: Column(
                        children: [
                          DefaultTextStyle(
                            style: TextStyle(color: Colors.white, fontSize: 12),
                            child: IconTheme(
                              data: IconThemeData(color: Colors.white),
                              child: Row(
                                children: [
                                  // 播放量和点赞
                                  Icon(Icons.play_circle_outline, size: 14),
                                  const SizedBox(width: 2),
                                  Text(_formatCount(video.stat?.view)),
                                  const SizedBox(width: 12),
                                  Icon(Icons.list_alt_outlined, size: 14),
                                  const SizedBox(width: 2),
                                  Text(_formatCount(video.stat?.danmaku)),
                                  const Spacer(),
                                  // 时长
                                  Text(_formatDuration(video.duration ?? 0)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 标题、UP
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (_, BoxConstraints constraints) {
                        final maxWidth = constraints.maxWidth;
                        return Text(
                          style: TextStyle(fontSize: maxWidth / 12),
                          video.title ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                    const Spacer(),
                    // UP主
                    DefaultTextStyle(
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      child: Row(
                        children: [
                          Text('[up] '),
                          Text(video.owner?.name ?? ''),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/service/recommend_service.dart';
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
      final service = context.read<RecommendService>();
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
    
    return Consumer<RecommendService>(
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 800;
              final crossAxisCount = isWide ? 4 : 2;

              return GridView.builder(
                key: service.gridKey,
                controller: service.scrollController,
                padding: const EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
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
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildVideoCard(RecVideoItem video) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (video.bvid != null) {
            Navigator.pushNamed(
              context,
              '/video',
              arguments: video.bvid,
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (video.cover != null)
                    CachedNetworkImage(
                      imageUrl: video.cover!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    )
                  else
                    Container(color: Colors.grey[300]),
                  // 时长
                  if (video.duration != null)
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
                          _formatDuration(video.duration!),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // 标题和信息
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
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
                    const Spacer(),
                    // UP主
                    if (video.owner?.name != null)
                      Text(
                        video.owner!.name!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    const SizedBox(height: 4),
                    // 播放量和点赞
                    Row(
                      children: [
                        Icon(Icons.play_circle_outline,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 2),
                        Text(
                          _formatCount(video.stat?.view),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.thumb_up_outlined,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 2),
                        Text(
                          _formatCount(video.stat?.like),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
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

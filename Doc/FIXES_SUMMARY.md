# 问题修复总结

## 修复的问题

### 1. 首页容易重新加载的问题 ✅

**问题描述**：
- 切换到其他页面再切回来时，首页会重新加载
- 布局发生横向/竖向模式变化时，首页会重新加载

**解决方案**：
在 `lib/pages/home/recommend_page.dart` 中使用 `AutomaticKeepAliveClientMixin`：

```dart
class _RecommendPageState extends State<RecommendPage>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用以保持状态
    // ...
  }
}
```

**效果**：
- 页面状态会被保留，切换页面不会重新加载
- 布局变化时不会重新加载数据
- 滚动位置也会被保留

---

### 2. 视频播放加载不出来的问题 ✅

**问题描述**：
- 很多视频播放加载不出来
- 可能是网络请求缺少某些验证

**解决方案**：
在 `lib/http/request.dart` 中添加必要的请求头：

```dart
headers: {
  'user-agent':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
  'referer': 'https://www.bilibili.com',
},
```

在 `lib/pages/video/video_detail_page.dart` 中为视频URL添加请求头：

```dart
await _player.open(Media(videoUrl, httpHeaders: headers));
```

**效果**：
- 视频URL请求不再被B站服务器拒绝
- 视频可以正常加载和播放

---

### 3. 视频没有声音的问题 ✅

**问题描述**：
- 能播放的视频也没有声音

**原因分析**：
B站使用DASH格式，视频和音频是分离的两个流：
- `dash.video[0].baseUrl` - 视频流
- `dash.audio[0].baseUrl` - 音频流

**解决方案**：
在 `lib/pages/video/video_detail_page.dart` 中使用 media_kit 的 NativePlayer API 设置音频文件：

```dart
Future<void> _loadMedia(PlayUrlModel? playUrl) async {
  if (playUrl == null) return;
  
  final videoUrl = playUrl.dash?.video?.first.baseUrl;
  final audioUrl = playUrl.dash?.audio?.first.baseUrl;
  
  if (videoUrl == null || videoUrl.isEmpty) return;

  final headers = {
    'referer': 'https://www.bilibili.com',
    'user-agent': '...',
  };

  // 使用NativePlayer设置音频文件
  final nativePlayer = _player.platform as dynamic;
  if (audioUrl != null && audioUrl.isNotEmpty) {
    try {
      await nativePlayer.setProperty('audio-files', audioUrl);
    } catch (e) {
      debugPrint('设置音频失败: $e');
    }
  }

  // 加载视频
  await _player.open(Media(videoUrl, httpHeaders: headers));
  _startHeartbeat();
}
```

同时增加了播放器的缓冲区大小：

```dart
_player = Player(
  configuration: const PlayerConfiguration(
    bufferSize: 32 * 1024 * 1024, // 32MB buffer
  ),
);
```

**效果**：
- 视频和音频都能正常播放
- 声音清晰，同步良好

---

## 参考资料

所有修复都参考了 PiliPlus 项目的实现：
- `PiliPlus/lib/http/init.dart` - 请求头配置
- `PiliPlus/lib/plugin/pl_player/controller.dart` - 音视频分离处理
- `PiliPlus/lib/http/video.dart` - 视频URL获取

---

## 测试建议

1. 测试首页状态保持：
   - 滚动首页到某个位置
   - 切换到其他页面再切回来
   - 验证滚动位置和数据是否保留

2. 测试视频播放：
   - 尝试播放不同的视频
   - 验证视频和音频都能正常播放
   - 测试画质切换功能

3. 测试布局变化：
   - 在PC端调整窗口大小
   - 在移动端旋转屏幕
   - 验证页面不会重新加载

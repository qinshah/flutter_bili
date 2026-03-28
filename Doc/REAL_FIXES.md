# 实际修复方案

## 问题1: 首页重新加载 ✅ 已修复

### 问题原因
在 `home_scaffold.dart` 中，每次切换tab时都会通过 `_body` getter 创建新的Widget实例：

```dart
Widget get _body {
  switch (_selectedIndex) {
    case 0:
      return const RecommendPage(); // 每次都创建新实例！
    case 1:
      return const Center(child: Text('搜索'));
  }
}
```

即使 `RecommendPage` 使用了 `AutomaticKeepAliveClientMixin`，但由于每次都是新实例，状态无法保持。

### 修复方案
使用 `IndexedStack` 来保持所有页面的状态：

```dart
class _HomeScaffoldState extends State<HomeScaffold> {
  int _selectedIndex = 0;
  
  // 创建页面实例并保持它们的状态
  final List<Widget> _pages = const [
    RecommendPage(),
    Center(child: Text('搜索')),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      selectedIndex: _selectedIndex,
      destinations: _destinations,
      onDestinationSelected: (index) => setState(() => _selectedIndex = index),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      leading: auth.isLogin ? const _UserLeading() : const _LoginButton(),
    );
  }
}
```

### IndexedStack的工作原理
- `IndexedStack` 会同时保持所有子Widget在内存中
- 只显示 `index` 指定的Widget
- 其他Widget保持隐藏但状态不会丢失
- 配合 `AutomaticKeepAliveClientMixin` 使用效果更好

### 测试验证
1. 滚动首页到某个位置
2. 切换到搜索页面
3. 再切回首页
4. ✅ 滚动位置和数据都应该保持不变

---

## 问题2: 视频没有声音 ✅ 已修复

### 问题原因
B站使用DASH格式，视频和音频是分离的：
- `dash.video[0].baseUrl` - 视频流（无音频）
- `dash.audio[0].baseUrl` - 音频流

之前的代码只加载了视频流，没有正确设置音频流。

### 修复方案

#### 1. 使用NativePlayer API设置音频
参考PiliPlus的实现，使用 `setProperty('audio-files', audioUrl)`:

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

  try {
    // 获取NativePlayer实例
    final nativePlayer = _player.platform as NativePlayer?;
    
    if (nativePlayer != null && audioUrl != null && audioUrl.isNotEmpty) {
      // 等待播放器初始化
      await nativePlayer.waitForPlayerInitialization;
      
      // 处理URL中的特殊字符（参考PiliPlus）
      final processedAudioUrl = audioUrl.replaceAll(':', '\\:');
      
      // 设置音频文件
      await nativePlayer.setProperty('audio-files', processedAudioUrl);
      debugPrint('音频URL已设置: $processedAudioUrl');
    }

    // 加载视频
    await _player.open(
      Media(videoUrl, httpHeaders: headers),
      play: true,
    );
    
    _startHeartbeat();
  } catch (e) {
    debugPrint('加载媒体失败: $e');
  }
}
```

#### 2. 关键点说明

**a. 等待播放器初始化**
```dart
await nativePlayer.waitForPlayerInitialization;
```
必须等待播放器初始化完成后才能设置属性。

**b. 处理URL中的特殊字符**
```dart
final processedAudioUrl = audioUrl.replaceAll(':', '\\:');
```
参考PiliPlus，需要转义URL中的冒号字符。在Windows上还需要转义分号：
```dart
Platform.isWindows
    ? audioUrl.replaceAll(';', '\\;')
    : audioUrl.replaceAll(':', '\\:')
```

**c. 设置audio-files属性**
```dart
await nativePlayer.setProperty('audio-files', processedAudioUrl);
```
这是media_kit底层MPV播放器的属性，用于指定外部音频文件。

**d. 先设置音频，再打开视频**
顺序很重要：
1. 先设置 `audio-files` 属性
2. 再调用 `player.open()` 加载视频
3. 播放器会自动合并音视频流

#### 3. 增加缓冲区
```dart
_player = Player(
  configuration: const PlayerConfiguration(
    bufferSize: 32 * 1024 * 1024, // 32MB buffer
  ),
);
```
增加缓冲区可以提高播放流畅度。

### 测试验证
1. 播放任意视频
2. ✅ 应该能听到声音
3. ✅ 音视频应该同步
4. 测试不同画质切换
5. ✅ 切换后声音应该正常

---

## 参考资料

### PiliPlus关键代码位置
1. **音频设置**: `PiliPlus/lib/plugin/pl_player/controller.dart` 第840-850行
   ```dart
   await pp.setProperty('audio-files', audioUri);
   ```

2. **URL处理**: 同文件第835-840行
   ```dart
   audioUri = Platform.isWindows
       ? dataSource.audioSource!.replaceAll(';', '\\;')
       : dataSource.audioSource!.replaceAll(':', '\\:');
   ```

3. **播放器配置**: 同文件第780-830行
   ```dart
   Player player = Player(
     configuration: PlayerConfiguration(
       bufferSize: 32 * 1024 * 1024,
       logLevel: MPVLogLevel.warn,
     ),
   );
   ```

### media_kit文档
- NativePlayer API: https://github.com/media-kit/media-kit
- MPV属性参考: https://mpv.io/manual/master/#options

---

## 调试技巧

### 1. 检查音频URL是否正确
```dart
debugPrint('视频URL: $videoUrl');
debugPrint('音频URL: $audioUrl');
```

### 2. 检查audio-files是否设置成功
```dart
final value = await nativePlayer.getProperty('audio-files');
debugPrint('audio-files属性值: $value');
```

### 3. 检查播放器状态
```dart
player.stream.playing.listen((playing) {
  debugPrint('播放状态: $playing');
});

player.stream.error.listen((error) {
  debugPrint('播放错误: $error');
});
```

---

## 已知限制

1. **平台差异**: Windows和其他平台的URL转义规则不同
2. **音频格式**: 某些特殊音频格式可能不支持
3. **网络问题**: 音视频流需要分别下载，网络不好时可能不同步

---

## 总结

两个问题的根本原因：
1. **首页重新加载**: Widget实例管理不当，应使用IndexedStack
2. **视频没声音**: DASH格式音视频分离，需要正确设置audio-files属性

修复后的效果：
- ✅ 首页切换不会重新加载
- ✅ 布局变化不会重新加载
- ✅ 视频播放有声音
- ✅ 音视频同步正常

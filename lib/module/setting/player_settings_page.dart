import 'package:flutter/material.dart';
import 'package:flutter_bili/service/media_s.dart';
import 'package:flutter_bili/service/settings_s.dart';

class PlayerSettingsPage extends StatefulWidget {
  const PlayerSettingsPage({super.key});

  @override
  State<PlayerSettingsPage> createState() => _PlayerSettingsPageState();
}

class _PlayerSettingsPageState extends State<PlayerSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('播放设置')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionTitle('播放器'),
          _buildPlayerLibraryTile(),
          _buildDivider(),
          _buildSectionTitle('弹幕'),
          _buildListTile(
            title: '启用弹幕',
            subtitle: Setting.enableDanmaku.get() ? '开启' : '关闭',
            onTap: () => _showDanmakuDialog(),
          ),
          _buildDivider(),
          _buildSectionTitle('播放'),
          _buildListTile(
            title: '自动播放',
            subtitle: Setting.autoPlay.get() ? '开启' : '关闭',
            onTap: () => _showAutoPlayDialog(),
          ),
          _buildDivider(),
          _buildSectionTitle('画质'),
          _buildVideoQualityTile(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPlayerLibraryTile() {
    return ListTile(
      title: const Text('播放器内核'),
      subtitle: Text(Setting.playerKernel.get().name),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () => _showPlayerLibraryDialog(),
    );
  }

  Widget _buildVideoQualityTile() {
    return ListTile(
      title: const Text('默认画质'),
      subtitle: Text(Setting.videoQuality.get().name),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () => _showVideoQualityDialog(),
    );
  }

  void _showPlayerLibraryDialog() {
    PlayerKernel selectedLibrary = Setting.playerKernel.get();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择播放器内核'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(PlayerKernel.values.length, (index) {
              return RadioListTile<PlayerKernel>(
                title: Text(PlayerKernel.values[index].name),
                value: PlayerKernel.values[index],
                groupValue: selectedLibrary,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => selectedLibrary = value);
                },
              );
            }),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Setting.playerKernel.set(selectedLibrary);
              MediaS.initPlayerKernel(selectedLibrary);
              setState(() {
                // 刷新页面
              });
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('播放器内核已更新')));
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showDanmakuDialog() {
    final enableDanmaku = Setting.enableDanmaku.get();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('弹幕设置'),
        content: SwitchListTile(
          title: const Text('启用弹幕'),
          value: enableDanmaku,
          onChanged: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Setting.enableDanmaku.set(!enableDanmaku);
              setState(() {
                // 刷新页面
              });
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('弹幕设置已更新')));
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showAutoPlayDialog() {
    final autoPlay = Setting.autoPlay.get();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('自动播放设置'),
        content: SwitchListTile(
          title: const Text('自动播放'),
          value: autoPlay,
          onChanged: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Setting.autoPlay.set(!autoPlay);
              setState(() {
                // 刷新页面
              });
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('自动播放设置已更新')));
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showVideoQualityDialog() {
    var selectedQuality = Setting.videoQuality.get();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择默认画质'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(VideoQualityM.values.length, (index) {
                return RadioListTile<VideoQualityM>(
                  title: Text(VideoQualityM.values[index].name),
                  value: VideoQualityM.values[index],
                  groupValue: selectedQuality,
                  onChanged: (value) {
                    if (value == null) return;
                    selectedQuality = value;
                  },
                );
              }),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Setting.videoQuality.set(selectedQuality);
              setState(() {
                // 刷新页面
              });
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('画质设置已更新')));
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1);
  }
}

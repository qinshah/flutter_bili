import 'package:flutter/material.dart';

import 'model/setting_m.dart';
import '../../service/storage_s.dart';

class PlayerSettingsPage extends StatefulWidget {
  const PlayerSettingsPage({super.key});

  @override
  State<PlayerSettingsPage> createState() => _PlayerSettingsPageState();
}

class _PlayerSettingsPageState extends State<PlayerSettingsPage> {
  SettingM _settings = SettingM();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _settings = StorageS.getLocal();
    });
  }

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
            subtitle: _settings.enableDanmaku ? '开启' : '关闭',
            onTap: () => _showDanmakuDialog(),
          ),
          _buildDivider(),
          _buildSectionTitle('播放'),
          _buildListTile(
            title: '自动播放',
            subtitle: _settings.autoPlay ? '开启' : '关闭',
            onTap: () => _showAutoPlayDialog(),
          ),
          _buildListTile(
            title: '默认静音',
            subtitle: _settings.muteByDefault ? '开启' : '关闭',
            onTap: () => _showMuteDialog(),
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
      title: const Text('播放器库'),
      subtitle: Text(
        _settings.playerLibrary == PlayerLibraryM.mediaKit ? 'media_kit' : 'fvp',
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () => _showPlayerLibraryDialog(),
    );
  }

  Widget _buildVideoQualityTile() {
    return ListTile(
      title: const Text('默认画质'),
      subtitle: Text(_settings.videoQuality.name),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () => _showVideoQualityDialog(),
    );
  }

  void _showPlayerLibraryDialog() {
    PlayerLibraryM? selectedLibrary = _settings.playerLibrary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择播放器库'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<PlayerLibraryM>(
                title: const Text('media_kit'),
                value: PlayerLibraryM.mediaKit,
                groupValue: selectedLibrary,
                onChanged: (value) {
                  setState(() => selectedLibrary = value);
                },
              ),
              RadioListTile<PlayerLibraryM>(
                title: const Text('fvp'),
                value: PlayerLibraryM.fvp,
                groupValue: selectedLibrary,
                onChanged: (value) {
                  setState(() => selectedLibrary = value);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              if (selectedLibrary != null) {
                Navigator.pop(context);
                await StorageS.saveSettings(
                  _settings.copyWith(playerLibrary: selectedLibrary!),
                );
                _loadSettings();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('播放器库已更新')),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showDanmakuDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('弹幕设置'),
        content: SwitchListTile(
          title: const Text('启用弹幕'),
          value: _settings.enableDanmaku,
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
              await StorageS.saveSettings(
                _settings.copyWith(enableDanmaku: !_settings.enableDanmaku),
              );
              _loadSettings();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('弹幕设置已更新')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showAutoPlayDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('自动播放设置'),
        content: SwitchListTile(
          title: const Text('自动播放'),
          value: _settings.autoPlay,
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
              await StorageS.saveSettings(
                _settings.copyWith(autoPlay: !_settings.autoPlay),
              );
              _loadSettings();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('自动播放设置已更新')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showMuteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('默认静音设置'),
        content: SwitchListTile(
          title: const Text('默认静音'),
          value: _settings.muteByDefault,
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
              await StorageS.saveSettings(
                _settings.copyWith(muteByDefault: !_settings.muteByDefault),
              );
              _loadSettings();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('默认静音设置已更新')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showVideoQualityDialog() {
    VideoQualityM selectedQuality = _settings.videoQuality;
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
                    setState(() => selectedQuality = value);
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
              await StorageS.saveSettings(
                _settings.copyWith(videoQuality: selectedQuality),
              );
              _loadSettings();
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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'model/settings_m.dart';
import '../../service/storage_s.dart';

class DataSettingsPage extends StatefulWidget {
  const DataSettingsPage({super.key});

  @override
  State<DataSettingsPage> createState() => _DataSettingsPageState();
}

class _DataSettingsPageState extends State<DataSettingsPage> {
  late SettingsM _settings;

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

  Future<void> _copy(String json) async {
    await Clipboard.setData(ClipboardData(text: json));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('数据管理')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionTitle('数据操作'),
          _buildImportTile(),
          _buildExportTile(),
          _buildResetTile(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildImportTile() {
    return ListTile(
      leading: const Icon(Icons.upload),
      title: const Text('导入数据'),
      subtitle: const Text('通过 JSON 导入设置数据'),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () => _showImportDialog(),
    );
  }

  Widget _buildExportTile() {
    return ListTile(
      leading: const Icon(Icons.download),
      title: const Text('导出数据'),
      subtitle: const Text('复制当前设置的 JSON 数据'),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () => _showExportDialog(),
    );
  }

  Widget _buildResetTile() {
    return ListTile(
      leading: const Icon(Icons.refresh),
      title: const Text('恢复默认设置'),
      subtitle: const Text('将所有设置恢复为默认值'),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () => _showResetDialog(),
    );
  }

  String _formatJson(Map<String, dynamic> json) {
    return JsonEncoder.withIndent('  ').convert(json);
  }

  Future<void> _showImportDialog() async {
    final cntlr = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入数据'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('请输入或粘贴 JSON 数据：'),
            const SizedBox(height: 8),
            SingleChildScrollView(
              child: TextField(
                controller: cntlr,
                decoration: const InputDecoration(
                  hintText: '粘贴 JSON 数据',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(8),
                ),
                minLines: 1,
                maxLines: 8,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Clipboard.getData(Clipboard.kTextPlain).then((data) {
                if (data?.text != null) {
                  cntlr.text = data!.text!;
                }
              });
            },
            child: const Text('粘贴'),
          ),
          FilledButton(
            onPressed: () {
              try {
                final jsonData = jsonDecode(cntlr.text);
                final newSettings = SettingsM.fromJson(jsonData);
                StorageS.saveSettings(newSettings);
                _loadSettings();
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('数据导入成功')));
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('JSON 格式错误')));
              }
            },
            child: const Text('导入'),
          ),
        ],
      ),
    );
    cntlr.dispose();
  }

  void _showExportDialog() {
    final json = _formatJson(_settings.toJson());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导出数据'),
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              json,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          FilledButton(
            onPressed: () {
              _copy(json);
              Navigator.pop(context);
            },
            child: const Text('复制 JSON'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('恢复默认设置'),
        content: const Text('确定要将所有设置恢复为默认值吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await StorageS.saveSettings(SettingsM());
              _loadSettings();
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('已恢复默认设置')));
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
}

import 'package:flutter/material.dart';

/// 搜索页面
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '第一视角',
            border: InputBorder.none,
          ),
          onSubmitted: (value) {
            // TODO: 执行搜索
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                // TODO: 执行搜索
              }
            },
            child: const Text('搜索'),
          ),
        ],
      ),
      body: ListView(
        children: [
          // bilibili热搜
          _buildSection(
            theme,
            'bilibili热搜',
            [
              _buildHotItem('万字解析BLG战胜G...', isHot: true),
              _buildHotItem('三角洲行动炸火联...'),
              _buildHotItem('SpaceX冲击史上最...', isNew: true),
              _buildHotItem('复盘李钟硕职业生涯'),
              _buildHotItem('怎么看大疆起诉影石'),
              _buildHotItem('美特使认为美伊本...'),
              _buildHotItem('华强买瓜但全员社恐', isHot: true),
              _buildHotItem('看季如何养胃护胃'),
            ],
          ),
          const Divider(height: 1),
          
          // 搜索发现
          _buildSection(
            theme,
            '搜索发现',
            [
              _buildDiscoveryItem('心理委员来了'),
              _buildDiscoveryItem('极客湾G... 22小时前更新'),
              _buildDiscoveryItem('永维塔菲 48分钟前更新'),
              _buildDiscoveryItem('俺不中了'),
              _buildDiscoveryItem('开源鸿蒙x86'),
              _buildDiscoveryItem('张宇27考研数学基础30讲'),
              _buildDiscoveryItem('打火机'),
              _buildDiscoveryItem('千早爱音'),
              _buildDiscoveryItem('文龙龙'),
              _buildDiscoveryItem('开源鸿蒙 3天前更新'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('完整榜单'),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildHotItem(String text, {bool isHot = false, bool isNew = false}) {
    return ListTile(
      title: Row(
        children: [
          Expanded(child: Text(text)),
          if (isHot)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '热',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          if (isNew)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '新',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
        ],
      ),
      onTap: () {
        // TODO: 搜索该关键词
      },
    );
  }

  Widget _buildDiscoveryItem(String text) {
    return ListTile(
      title: Text(text),
      trailing: const Icon(Icons.search, size: 20),
      onTap: () {
        // TODO: 搜索该关键词
      },
    );
  }
}

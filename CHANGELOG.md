# 更新日志

> 记录每次代码变更的摘要。

## [Unreleased]

### Added
- 视频页嵌套滑动：NestedScrollView + SliverAppBar 实现视频区域随内容滚动折叠
- 暂停且折叠时显示"继续播放"按钮，点击恢复播放并展开视频
- VideoPageVm 添加 currentTabIndex / switchTab 管理 Tab 状态

### Changed
- 视频页窄屏布局：SingleChildScrollView → NestedScrollView（SliverAppBar + SliverPersistentHeader + TabBarView）
- TabController 从 DefaultTabController 改为 State 持有，防止状态丢失
- 简介/评论 Tab 内容由 VM 持有 Tab 索引，滚动位置通过 TabBarView child 保持
- 视频信息区域精简（简介和选集移入简介 Tab）
- 宽屏布局复用窄屏的 NestedScrollView 结构

### Fixed
- 修复切换简介/评论 Tab 时 Tab 索引和滚动位置丢失的问题

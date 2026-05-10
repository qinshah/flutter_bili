class SpaceArchiveData {
  final int count;
  final List<SpaceArchiveItem> items;
  final bool hasNext;

  SpaceArchiveData({
    required this.count,
    required this.items,
    this.hasNext = false,
  });

  factory SpaceArchiveData.fromJson(Map<String, dynamic> json) {
    return SpaceArchiveData(
      count: json['count'] as int? ?? 0,
      items: (json['item'] as List<dynamic>? ?? [])
          .map((e) => SpaceArchiveItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasNext: json['has_next'] as bool? ?? false,
    );
  }
}

class SpaceArchiveItem {
  final String? title;
  final String? bvid;
  final String? param;
  final String? cover;
  final int? duration;
  final int? play;
  final int? danmaku;
  final int? ctime;
  final String? author;
  final String? viewContent;
  final String? publishTimeText;
  final String? tname;

  SpaceArchiveItem({
    this.title,
    this.bvid,
    this.param,
    this.cover,
    this.duration,
    this.play,
    this.danmaku,
    this.ctime,
    this.author,
    this.viewContent,
    this.publishTimeText,
    this.tname,
  });

  factory SpaceArchiveItem.fromJson(Map<String, dynamic> json) {
    return SpaceArchiveItem(
      title: json['title'] as String?,
      bvid: json['bvid'] as String?,
      param: json['param'] as String?,
      cover: json['cover'] as String?,
      duration: json['duration'] as int?,
      play: json['play'] as int?,
      danmaku: json['danmaku'] as int?,
      ctime: json['ctime'] as int?,
      author: json['author'] as String?,
      viewContent: json['view_content'] as String?,
      publishTimeText: json['publish_time_text'] as String?,
      tname: json['tname'] as String?,
    );
  }
}

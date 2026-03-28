/// 相关推荐视频
class RelatedVideoItem {
  final int? aid;
  final String? bvid;
  final String? pic;
  final String? title;
  final int? duration;
  final Owner? owner;
  final Stat? stat;

  RelatedVideoItem({
    this.aid,
    this.bvid,
    this.pic,
    this.title,
    this.duration,
    this.owner,
    this.stat,
  });

  factory RelatedVideoItem.fromJson(Map<String, dynamic> json) {
    return RelatedVideoItem(
      aid: json['aid'],
      bvid: json['bvid'],
      pic: json['pic'],
      title: json['title'],
      duration: json['duration'],
      owner: json['owner'] != null ? Owner.fromJson(json['owner']) : null,
      stat: json['stat'] != null ? Stat.fromJson(json['stat']) : null,
    );
  }
}

class Owner {
  final int? mid;
  final String? name;
  final String? face;

  Owner({this.mid, this.name, this.face});

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      mid: json['mid'],
      name: json['name'],
      face: json['face'],
    );
  }
}

class Stat {
  final int? view;
  final int? danmaku;

  Stat({this.view, this.danmaku});

  factory Stat.fromJson(Map<String, dynamic> json) {
    return Stat(
      view: json['view'],
      danmaku: json['danmaku'],
    );
  }
}

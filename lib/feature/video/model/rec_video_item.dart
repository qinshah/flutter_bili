class RecVideoItem {
  int? aid;
  String? bvid;
  int? cid;
  String? cover;
  String? title;
  int? duration;
  int? pubdate;
  Owner? owner;
  Stat? stat;
  String? rcmdReason;

  RecVideoItem({
    this.aid,
    this.bvid,
    this.cid,
    this.cover,
    this.title,
    this.duration,
    this.pubdate,
    this.owner,
    this.stat,
    this.rcmdReason,
  });

  factory RecVideoItem.fromJson(Map<String, dynamic> json) {
    return RecVideoItem(
      aid: json['id'],
      bvid: json['bvid'],
      cid: json['cid'],
      cover: json['pic'],
      title: json['title'],
      duration: json['duration'],
      pubdate: json['pubdate'],
      owner: json['owner'] != null ? Owner.fromJson(json['owner']) : null,
      stat: json['stat'] != null ? Stat.fromJson(json['stat']) : null,
      rcmdReason: json['rcmd_reason']?['content'],
    );
  }
}

class Owner {
  int? mid;
  String? name;
  String? face;

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
  int? view;
  int? like;
  int? danmaku;

  Stat({this.view, this.like, this.danmaku});

  factory Stat.fromJson(Map<String, dynamic> json) {
    return Stat(
      view: json['view'],
      like: json['like'],
      danmaku: json['danmaku'],
    );
  }
}

class VideoDetailData {
  final String bvid;
  final int aid;
  final String title;
  final String pic;
  final String desc;
  final OwnerInfo owner;
  final StatInfo stat;
  final List<PageInfo> pages;

  const VideoDetailData({
    required this.bvid,
    required this.aid,
    required this.title,
    required this.pic,
    required this.desc,
    required this.owner,
    required this.stat,
    required this.pages,
  });

  factory VideoDetailData.fromJson(Map<String, dynamic> json) {
    return VideoDetailData(
      bvid: json['bvid'] as String,
      aid: json['aid'] as int,
      title: json['title'] as String,
      pic: json['pic'] as String,
      desc: json['desc'] as String,
      owner: OwnerInfo.fromJson(json['owner'] as Map<String, dynamic>),
      stat: StatInfo.fromJson(json['stat'] as Map<String, dynamic>),
      pages: (json['pages'] as List<dynamic>)
          .map((e) => PageInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OwnerInfo {
  final int mid;
  final String name;
  final String face;

  const OwnerInfo({
    required this.mid,
    required this.name,
    required this.face,
  });

  factory OwnerInfo.fromJson(Map<String, dynamic> json) {
    return OwnerInfo(
      mid: json['mid'] as int,
      name: json['name'] as String,
      face: json['face'] as String,
    );
  }
}

class StatInfo {
  final int view;
  final int like;
  final int coin;
  final int favorite;

  const StatInfo({
    required this.view,
    required this.like,
    required this.coin,
    required this.favorite,
  });

  factory StatInfo.fromJson(Map<String, dynamic> json) {
    return StatInfo(
      view: json['view'] as int,
      like: json['like'] as int,
      coin: json['coin'] as int,
      favorite: json['favorite'] as int,
    );
  }
}

class PageInfo {
  final int cid;
  final int page;
  final String part;
  final int duration;

  const PageInfo({
    required this.cid,
    required this.page,
    required this.part,
    required this.duration,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      cid: json['cid'] as int,
      page: json['page'] as int,
      part: json['part'] as String,
      duration: json['duration'] as int,
    );
  }
}

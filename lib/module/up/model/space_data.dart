class SpaceCard {
  final String? mid;
  final String? name;
  final String? face;
  final int? fans;
  final int? attention;
  final String? sign;
  final int? level;
  final OfficialVerify? officialVerify;
  final VipInfo? vip;

  SpaceCard({
    this.mid,
    this.name,
    this.face,
    this.fans,
    this.attention,
    this.sign,
    this.level,
    this.officialVerify,
    this.vip,
  });

  factory SpaceCard.fromJson(Map<String, dynamic> json) {
    return SpaceCard(
      mid: json['mid']?.toString(),
      name: json['name'] as String?,
      face: json['face'] as String?,
      fans: json['fans'] as int?,
      attention: json['attention'] as int?,
      sign: json['sign'] as String?,
      level: json['level_info']?['current_level'] as int?,
      officialVerify: json['Official']?['desc'] != null
          ? OfficialVerify(
              desc: json['Official']['desc'] as String?,
              type: json['Official']['type'] as int?,
            )
          : null,
      vip: json['vip'] != null ? VipInfo.fromJson(json['vip']) : null,
    );
  }
}

class OfficialVerify {
  final String? desc;
  final int? type;

  OfficialVerify({this.desc, this.type});
}

class VipInfo {
  final int? status;
  final int? type;
  final String? label;

  VipInfo({this.status, this.type, this.label});

  factory VipInfo.fromJson(Map<String, dynamic> json) {
    return VipInfo(
      status: json['status'] as int?,
      type: json['type'] as int?,
      label: json['label']?['text'] as String?,
    );
  }
}

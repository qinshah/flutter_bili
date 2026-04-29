/// 动态结果
class DynamicsResult {
  final bool? hasMore;
  final List<DynamicsItem> items;
  final String? offset;

  DynamicsResult({
    this.hasMore,
    required this.items,
    this.offset,
  });

  factory DynamicsResult.fromJson(Map<String, dynamic> json) {
    final List<DynamicsItem> items = [];
    if (json['items'] != null) {
      for (final item in json['items'] as List) {
        try {
          items.add(DynamicsItem.fromJson(item));
        } catch (e) {
          // 跳过解析失败的项
          continue;
        }
      }
    }
    
    return DynamicsResult(
      hasMore: json['has_more'],
      items: items,
      offset: json['offset'],
    );
  }
}

/// 动态项
class DynamicsItem {
  final String? idStr;
  final String? type;
  final DynamicsModules? modules;
  final DynamicsItem? orig; // 转发的原动态

  DynamicsItem({
    this.idStr,
    this.type,
    this.modules,
    this.orig,
  });

  factory DynamicsItem.fromJson(Map<String, dynamic> json) {
    return DynamicsItem(
      idStr: json['id_str'],
      type: json['type'],
      modules: json['modules'] != null
          ? DynamicsModules.fromJson(json['modules'])
          : null,
      orig: json['orig'] != null ? DynamicsItem.fromJson(json['orig']) : null,
    );
  }
}

/// 动态模块
class DynamicsModules {
  final ModuleAuthor? moduleAuthor;
  final ModuleDynamic? moduleDynamic;
  final ModuleStat? moduleStat;

  DynamicsModules({
    this.moduleAuthor,
    this.moduleDynamic,
    this.moduleStat,
  });

  factory DynamicsModules.fromJson(Map<String, dynamic> json) {
    return DynamicsModules(
      moduleAuthor: json['module_author'] != null
          ? ModuleAuthor.fromJson(json['module_author'])
          : null,
      moduleDynamic: json['module_dynamic'] != null
          ? ModuleDynamic.fromJson(json['module_dynamic'])
          : null,
      moduleStat: json['module_stat'] != null
          ? ModuleStat.fromJson(json['module_stat'])
          : null,
    );
  }
}

/// 作者信息
class ModuleAuthor {
  final int? mid;
  final String? name;
  final String? face;
  final String? pubTime;

  ModuleAuthor({
    this.mid,
    this.name,
    this.face,
    this.pubTime,
  });

  factory ModuleAuthor.fromJson(Map<String, dynamic> json) {
    return ModuleAuthor(
      mid: json['mid'],
      name: json['name'],
      face: json['face'],
      pubTime: json['pub_time'],
    );
  }
}

/// 动态内容
class ModuleDynamic {
  final DynamicDesc? desc;
  final DynamicMajor? major;

  ModuleDynamic({
    this.desc,
    this.major,
  });

  factory ModuleDynamic.fromJson(Map<String, dynamic> json) {
    return ModuleDynamic(
      desc: json['desc'] != null ? DynamicDesc.fromJson(json['desc']) : null,
      major:
          json['major'] != null ? DynamicMajor.fromJson(json['major']) : null,
    );
  }
}

/// 动态描述
class DynamicDesc {
  final String? text;

  DynamicDesc({this.text});

  factory DynamicDesc.fromJson(Map<String, dynamic> json) {
    return DynamicDesc(text: json['text']);
  }
}

/// 动态主要内容
class DynamicMajor {
  final String? type;
  final DynamicArchive? archive;

  DynamicMajor({
    this.type,
    this.archive,
  });

  factory DynamicMajor.fromJson(Map<String, dynamic> json) {
    return DynamicMajor(
      type: json['type'],
      archive: json['archive'] != null
          ? DynamicArchive.fromJson(json['archive'])
          : null,
    );
  }
}

/// 视频信息
class DynamicArchive {
  final String? bvid;
  final String? cover;
  final String? title;
  final String? durationText;
  final DynamicStat? stat;

  DynamicArchive({
    this.bvid,
    this.cover,
    this.title,
    this.durationText,
    this.stat,
  });

  factory DynamicArchive.fromJson(Map<String, dynamic> json) {
    return DynamicArchive(
      bvid: json['bvid'],
      cover: json['cover'],
      title: json['title'],
      durationText: json['duration_text'],
      stat: json['stat'] != null ? DynamicStat.fromJson(json['stat']) : null,
    );
  }
}

/// 视频统计
class DynamicStat {
  final String? play;
  final String? danmaku;

  DynamicStat({
    this.play,
    this.danmaku,
  });

  factory DynamicStat.fromJson(Map<String, dynamic> json) {
    return DynamicStat(
      play: json['play'],
      danmaku: json['danmaku'],
    );
  }
}

/// 动态统计
class ModuleStat {
  final DynamicStatCount? forward;
  final DynamicStatCount? comment;
  final DynamicStatCount? like;

  ModuleStat({
    this.forward,
    this.comment,
    this.like,
  });

  factory ModuleStat.fromJson(Map<String, dynamic> json) {
    return ModuleStat(
      forward: json['forward'] != null
          ? DynamicStatCount.fromJson(json['forward'])
          : null,
      comment: json['comment'] != null
          ? DynamicStatCount.fromJson(json['comment'])
          : null,
      like:
          json['like'] != null ? DynamicStatCount.fromJson(json['like']) : null,
    );
  }
}

/// 统计数量
class DynamicStatCount {
  final int? count;
  final bool? forbidden;

  DynamicStatCount({
    this.count,
    this.forbidden,
  });

  factory DynamicStatCount.fromJson(Map<String, dynamic> json) {
    return DynamicStatCount(
      count: json['count'],
      forbidden: json['forbidden'],
    );
  }
}

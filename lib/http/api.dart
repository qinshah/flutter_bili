import 'package:flutter_bili/http/constants.dart';

abstract final class Api {
  // 推荐视频
  static const String recommendListApp =
      '${HttpString.appBaseUrl}/x/v2/feed/index';
  static const String recommendListWeb = '/x/web-interface/index/top/feed/rcmd';

  // 热门视频
  static const String hotList = '/x/web-interface/popular';

  // 视频流
  static const String ugcUrl = '/x/player/wbi/playurl';

  // 番剧视频流
  static const String pgcUrl = '/pgc/player/web/v2/playurl';

  static const String pugvUrl = '/pugv/player/web/playurl';

  static const String tvPlayUrl = '/x/tv/playurl';

  // 字幕
  static const String playInfo = '/x/player/wbi/v2';

  // 视频详情
  static const String videoIntro = '/x/web-interface/view';

  // 点赞
  static const String likeVideo = '${HttpString.appBaseUrl}/x/v2/view/like';

  // 投币
  static const String coinVideo = '${HttpString.appBaseUrl}/x/v2/view/coin/add';

  // 收藏
  static const String favVideo = '/x/v3/fav/resource/batch-deal';

  // 一键三连
  static const String ugcTriple = '/x/web-interface/archive/like/triple';

  // 收藏夹
  static const String favFolder = '/x/v3/fav/folder/created/list-all';

  // 视频详情页 相关视频
  static const String relatedList = '/x/web-interface/archive/related';

  // 评论列表
  static const String replyList = '/x/v2/reply';

  // 楼中楼
  static const String replyReplyList = '/x/v2/reply/reply';

  // 评论点赞
  static const String likeReply = '/x/v2/reply/action';

  // 发表评论
  static const String replyAdd = '/x/v2/reply/add';

  // 删除评论
  static const String replyDel = '/x/v2/reply/del';

  // 用户信息
  static const String userInfo = '/x/web-interface/nav';

  // 获取当前用户状态
  static const String userStatOwner = '/x/web-interface/nav/stat';

  // 记录视频播放进度
  static const String heartBeat = '/x/click-interface/web/heartbeat';

  // 查询视频分P列表
  static const String ab2c = '/x/player/pagelist';

  // 番剧/剧集明细
  static const String pgcInfo = '/pgc/view/web/season';

  // 稍后再看
  static const String toViewLater = '/x/v2/history/toview/add';

  // 获取稍后再看
  static const String seeYouLater = '/x/v2/history/toview/web';

  // 获取历史记录
  static const String historyList = '/x/web-interface/history/cursor';

  // 搜索
  static const String searchByType = '/x/web-interface/wbi/search/type';

  // 热搜
  static const String hotSearchList = 'https://s.search.bilibili.com/main/hotword';

  // 默认搜索词
  static const String searchDefault = '/x/web-interface/wbi/search/default';

  // 关注的up动态
  static const String followDynamic = '/x/polymer/web-dynamic/v1/feed/all';

  // 登录相关
  static const String getTVCode =
      '${HttpString.passBaseUrl}/x/passport-tv-login/qrcode/auth_code';

  static const String qrcodePoll =
      '${HttpString.passBaseUrl}/x/passport-tv-login/qrcode/poll';

  static const String logout = '${HttpString.passBaseUrl}/login/exit/v2';
}

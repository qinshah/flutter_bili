abstract final class Api {
  // Base URLs
  static const String apiBaseUrl = 'https://api.bilibili.com';
  static const String passBaseUrl = 'https://passport.bilibili.com';
  
  // Login APIs
  /// 申请二维码(TV端)
  static const String getTVCode =
      '$passBaseUrl/x/passport-tv-login/qrcode/auth_code';
  
  /// 扫码登录（TV端）
  static const String qrcodePoll =
      '$passBaseUrl/x/passport-tv-login/qrcode/poll';
  
  // Video APIs
  /// 视频流
  static const String ugcUrl = '/x/player/wbi/playurl';
  
  /// 视频详情
  static const String videoIntro = '/x/web-interface/view';
  
  /// 字幕和播放信息
  static const String playInfo = '/x/player/wbi/v2';
  
  /// 记录视频播放进度
  static const String heartBeat = '/x/click-interface/web/heartbeat';
}

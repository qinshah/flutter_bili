class PlayingInfoM {
  PlayingInfoM({
    this.width,
    this.height,
    this.codec,
    this.decoder,
    this.quality,
    this.pixelFormat,
    this.frameRate,
  });

  /// 视频宽度
  final int? width;

  /// 视频高度
  final int? height;

  /// 编解码器名称（如 h264、hevc、av1）
  final String? codec;

  /// 解码方式（如 软解、硬解、VA-API、D3D11VA、VideoToolbox 等）
  final String? decoder;

  /// 画质名称（如 1080P60、4K30）
  final String? quality;

  /// 像素格式（如 yuv420p、nv12 等）
  final String? pixelFormat;

  /// 帧率
  final double? frameRate;

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'codec': codec,
      'decoder': decoder,
      'quality': quality,
      'pixelFormat': pixelFormat,
      'frameRate': frameRate,
    };
  }

  @override
  String toString() => toJson().toString();
}

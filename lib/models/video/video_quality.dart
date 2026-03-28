enum VideoQuality {
  q1080p60(116, '1080P60'),
  q1080p(80, '1080P'),
  q720p(64, '720P'),
  q480p(32, '480P'),
  q360p(16, '360P');

  const VideoQuality(this.code, this.label);
  final int code;
  final String label;
  static const List<int> priorityOrder = [116, 80, 64, 32, 16];
}

enum MdkVideoDecoder {
  dav1d(description: '通过dav1d实现的av1软解'),
  // ignore: constant_identifier_names
  FFmpeg(description: 'ffmpeg解码'),
  // ignore: constant_identifier_names
  OH(description: '鸿蒙系统解码');

  final String description;

  const MdkVideoDecoder({required this.description});

  @override
  toString() => '$name($description)';
}

import 'dart:convert';

import 'package:crypto/crypto.dart';

abstract final class AppSign {
  static const String _appKey = 'dfca71928277209b';
  static const String _appSec = 'b5475a8825547a4fc26c7d518eaaa02e';

  /// 注入 appkey/ts，按 key 排序后 MD5 签名，结果写入 [params]['sign']。
  static void appSign(Map<String, dynamic> params) {
    params['appkey'] = _appKey;
    params['ts'] = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

    final sorted = params.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final query = _buildQuery(sorted);
    params['sign'] = md5.convert(utf8.encode(query + _appSec)).toString();
  }

  static String _buildQuery(
    List<MapEntry<String, dynamic>> entries,
  ) {
    final buf = StringBuffer();
    var sep = '';
    for (final entry in entries) {
      final value = entry.value;
      if (value is Iterable) {
        for (final v in value) {
          buf
            ..write(sep)
            ..write(Uri.encodeQueryComponent(entry.key))
            ..write('=')
            ..write(Uri.encodeQueryComponent(v.toString()));
          sep = '&';
        }
      } else {
        final str = value?.toString();
        buf.write(sep);
        sep = '&';
        buf.write(Uri.encodeQueryComponent(entry.key));
        if (str != null && str.isNotEmpty) {
          buf
            ..write('=')
            ..write(Uri.encodeQueryComponent(str));
        }
      }
    }
    return buf.toString();
  }
}

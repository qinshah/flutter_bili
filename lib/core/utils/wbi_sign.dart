// Wbi 签名 — 生成 REST API 请求中的 w_rid 和 wts 字段
// https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/misc/sign/wbi.md
import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_bili/core/http/api.dart';
import 'package:flutter_bili/core/http/request.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../service/storage_s.dart';

abstract final class WbiSign {
  static final List<int> _mixinKeyEncTab = [
    46,
    47,
    18,
    2,
    53,
    8,
    23,
    32,
    15,
    50,
    10,
    31,
    58,
    3,
    45,
    35,
    27,
    43,
    5,
    49,
    33,
    9,
    42,
    19,
    29,
    28,
    14,
    39,
    12,
    38,
    41,
    13,
    37,
    48,
    7,
    16,
    24,
    55,
    40,
    61,
    26,
    17,
    0,
    1,
    60,
    51,
    30,
    4,
    22,
    25,
    54,
    21,
    56,
    59,
    6,
    63,
    57,
    62,
    11,
    36,
    20,
    34,
    44,
    52,
  ];

  static const _navUrl = 'https://api.bilibili.com/x/web-interface/nav';

  // Characters that must be stripped before URL-encoding per Bilibili spec.
  static final RegExp _chrFilter = RegExp(r"[!'\(\)\*]");

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Signs [params] in-place and returns the same map with `w_rid` and `wts`.
  static Future<Map<String, Object>> makSign(Map<String, Object> params) async {
    final mixinKey = await getWbiKeys();
    _encWbi(params, mixinKey);
    return params;
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  // 对 imgKey 和 subKey 进行字符顺序打乱编码
  static String _getMixinKey(String orig) {
    final codeUnits = orig.codeUnits;
    return String.fromCharCodes(_mixinKeyEncTab.map((i) => codeUnits[i]));
  }

  static void _encWbi(Map<String, Object> params, String mixinKey) {
    params['wts'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    // 按照 key 重排参数
    final keys = params.keys.toList()..sort();
    final queryStr = keys
        .map(
          (i) =>
              '${Uri.encodeComponent(i)}=${Uri.encodeComponent(params[i].toString().replaceAll(_chrFilter, ''))}',
        )
        .join('&');
    params['w_rid'] = md5
        .convert(utf8.encode(queryStr + mixinKey))
        .toString(); // 计算 w_rid
  }

  static final Box<dynamic> _cacheB = StorageS.cacheB;

  static Future<String> getWbiKeys() async {
    final nowDate = DateTime.now();
    final cachedTs = _cacheB.get('wbiTimestamp', defaultValue: 0) as int;
    final cachedDate = DateTime.fromMillisecondsSinceEpoch(
      cachedTs,
    );
    final mixinKey = _cacheB.get('mixinKey') as String?;
    if (cachedDate.day == nowDate.day && mixinKey != null) return mixinKey;

    final newWbiKeys = await _getNewWbiKeys();
    await _cacheB.put('wbiTimestamp', nowDate.millisecondsSinceEpoch);
    await _cacheB.put('mixinKey', newWbiKeys);
    return newWbiKeys;
  }

  static Future<String> _getNewWbiKeys() async {
    final res = await Request().get(Api.userInfo);
    try {
      final wbiUrls = res.data['data']['wbi_img'];

      final imgUrl = wbiUrls['img_url'] as String;
      final subUrl = wbiUrls['sub_url'] as String;
      final mixinKey = _getMixinKey(
        imgUrl
                .substring(imgUrl.lastIndexOf('/') + 1, imgUrl.length)
                .split('.')[0] +
            subUrl
                .substring(subUrl.lastIndexOf('/') + 1, subUrl.length)
                .split('.')[0],
      );
      print('新Wbi 签名: $mixinKey');
      return mixinKey;
    } catch (e) {
      print('获取 Wbi 签名失败: $e');
      return '';
    }
  }
}

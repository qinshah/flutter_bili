// Wbi 签名 — 生成 REST API 请求中的 w_rid 和 wts 字段
// https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/misc/sign/wbi.md
import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../../service/storage_service.dart';

abstract final class WbiSign {
  static const _mixinKeyEncTab = <int>[
    46, 47, 18, 2,  53, 8,  23, 32, 15, 50, 10, 31, 58, 3,  45, 35,
    27, 43, 5,  49, 33, 9,  42, 19, 29, 28, 14, 39, 12, 38, 41, 13,
    37, 48, 7,  16, 24, 55, 40, 61, 26, 17, 0,  1,  60, 51, 30, 4,
    22, 25, 54, 21, 56, 59, 6,  63, 57, 62, 11, 36, 20, 34, 44, 52,
  ];

  static const _navUrl = 'https://api.bilibili.com/x/web-interface/nav';

  // Characters that must be stripped before URL-encoding per Bilibili spec.
  static final RegExp _chrFilter = RegExp(r"[!'\(\)\*]");

  static Future<String>? _pendingFetch;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Signs [params] in-place and returns the same map with `w_rid` and `wts`.
  static Future<Map<String, Object>> makSign(Map<String, Object> params) async {
    final mixinKey = await _getOrRefreshMixinKey();
    _encWbi(params, mixinKey);
    return params;
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Reorders characters of [orig] using the shuffle table and returns first 32.
  static String getMixinKey(String orig) {
    final units = orig.codeUnits;
    return String.fromCharCodes(
      _mixinKeyEncTab.map((i) => units[i]),
    ).substring(0, 32);
  }

  static void _encWbi(Map<String, Object> params, String mixinKey) {
    params['wts'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final keys = params.keys.toList()..sort();
    final query = keys.map((k) {
      final v = params[k].toString().replaceAll(_chrFilter, '');
      return '${Uri.encodeComponent(k)}=${Uri.encodeComponent(v)}';
    }).join('&');

    params['w_rid'] = md5.convert(utf8.encode(query + mixinKey)).toString();
  }

  static FutureOr<String> _getOrRefreshMixinKey() {
    final now = DateTime.now();
    final cachedTs = StorageService.cache.get('wbiTimestamp', defaultValue: 0) as int;
    final cachedKey = StorageService.cache.get('mixinKey') as String?;

    // Same calendar day → reuse cached key.
    if (cachedKey != null &&
        DateTime.fromMillisecondsSinceEpoch(cachedTs).day == now.day) {
      return cachedKey;
    }

    // Need refresh — deduplicate concurrent calls.
    return _pendingFetch ??= _fetchAndCache(now).whenComplete(() {
      _pendingFetch = null;
    });
  }

  static Future<String> _fetchAndCache(DateTime now) async {
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      final resp = await dio.get(_navUrl);
      final wbiImg = resp.data['data']['wbi_img'] as Map<String, dynamic>;

      final imgKey = _fileNameWithoutExt(wbiImg['img_url'] as String);
      final subKey = _fileNameWithoutExt(wbiImg['sub_url'] as String);
      final mixinKey = getMixinKey(imgKey + subKey);

      await StorageService.cache.put('wbiTimestamp', now.millisecondsSinceEpoch);
      await StorageService.cache.put('mixinKey', mixinKey);

      return mixinKey;
    } catch (_) {
      // Return cached key if available, otherwise empty string.
      return StorageService.cache.get('mixinKey') as String? ?? '';
    }
  }

  /// Extracts the filename without extension from a URL path.
  static String _fileNameWithoutExt(String url) {
    final path = Uri.parse(url).pathSegments.last;
    final dot = path.lastIndexOf('.');
    return dot == -1 ? path : path.substring(0, dot);
  }
}

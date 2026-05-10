import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:brotli/brotli.dart';
import 'package:dio/dio.dart';

import 'auth_interceptor.dart';
import 'retry_interceptor.dart';

class Request {
  static const _gzipDecoder = GZipDecoder();
  static const _brotliDecoder = BrotliDecoder();
  static final Request _instance = Request._internal();
  factory Request() => _instance;

  late final Dio dio;

  Request._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.bilibili.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'user-agent': 'Dart/3.6 (dart:io)',
          'env': 'prod',
          'app-key': 'android64',
          'x-bili-aurora-zone': 'sh001',
          'referer': 'https://www.bilibili.com/',
        },
      ),
    );
    dio.interceptors.addAll([
      RetryInterceptor(dio: dio),
      AuthInterceptor(),
    ]);
  }

  static String _responseDecoder(
    List<int> responseBytes,
    RequestOptions options,
    ResponseBody responseBody,
  ) => utf8.decode(
    responseBytesDecoder(responseBytes, responseBody.headers),
    allowMalformed: true,
  );
  static List<int> responseBytesDecoder(
    List<int> responseBytes,
    Map<String, List<String>> headers,
  ) => switch (headers['content-encoding']?.firstOrNull) {
    'gzip' => _gzipDecoder.decodeBytes(responseBytes),
    'br' => _brotliDecoder.convert(responseBytes),
    _ => responseBytes,
  };

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.get(url, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.post(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

import 'package:dio/dio.dart';
import 'auth_interceptor.dart';
import 'retry_interceptor.dart';

class Request {
  static final Request _instance = Request._internal();
  factory Request() => _instance;

  late final Dio dio;

  Request._internal() {
    dio = Dio(BaseOptions(
      baseUrl: 'https://api.bilibili.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ));
    dio.interceptors.addAll([
      RetryInterceptor(dio: dio),
      AuthInterceptor(),
    ]);
  }

  Future<Response> get(String url,
      {Map<String, dynamic>? queryParameters, Options? options}) {
    return dio.get(url, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(String url,
      {Object? data,
      Map<String, dynamic>? queryParameters,
      Options? options}) {
    return dio.post(url,
        data: data, queryParameters: queryParameters, options: options);
  }
}

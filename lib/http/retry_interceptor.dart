import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only retry on these error types
    final retryableTypes = {
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.unknown,
    };

    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (retryableTypes.contains(err.type) && retryCount < maxRetries) {
      err.requestOptions.extra['retryCount'] = retryCount + 1;
      await Future.delayed(retryDelay);
      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // Will be caught by next interceptor call
      }
    }
    handler.next(err);
  }
}

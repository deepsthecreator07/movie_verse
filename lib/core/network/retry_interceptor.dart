import 'dart:math';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

/// Dio interceptor that retries failed requests with exponential backoff.
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration baseDelay;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = ApiConstants.maxRetries,
    this.baseDelay = ApiConstants.retryBaseDelay,
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldRetry(err)) {
      final attempt = err.requestOptions.extra['retryAttempt'] ?? 0;

      if (attempt < maxRetries) {
        final delay = baseDelay * pow(2, attempt).toInt();
        await Future.delayed(delay);

        err.requestOptions.extra['retryAttempt'] = attempt + 1;

        try {
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } on DioException catch (e) {
          return handler.next(e);
        }
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500);
  }
}

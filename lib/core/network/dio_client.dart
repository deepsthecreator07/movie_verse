import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'retry_interceptor.dart';

/// Pre-configured Dio HTTP client for MovieVerse.
class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-api-key': ApiConstants.reqresApiKey,
        },
      ),
    );

    // Add retry interceptor
    _dio.interceptors.add(
      RetryInterceptor(dio: _dio),
    );

    // Logging in debug mode
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (log) {
          // Only log in debug mode — this will be optimized out in release
          assert(() {
            // ignore: avoid_print
            print(log);
            return true;
          }());
        },
      ),
    );
  }

  Dio get dio => _dio;

  /// GET request with optional query parameters.
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
  }) {
    return _dio.get(
      baseUrl != null ? '$baseUrl$path' : path,
      queryParameters: queryParameters,
    );
  }

  /// POST request with optional body.
  Future<Response> post(
    String path, {
    dynamic data,
    String? baseUrl,
  }) {
    return _dio.post(
      baseUrl != null ? '$baseUrl$path' : path,
      data: data,
    );
  }
}

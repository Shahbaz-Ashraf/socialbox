import 'package:dio/dio.dart';

/// Singleton HTTP client. Use [withBearerToken] for authenticated API calls.
class DioClient {
  DioClient._();

  static final DioClient instance = DioClient._();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: const {'Content-Type': 'application/json'},
    ),
  );

  Dio get dio => _dio;

  /// Returns a Dio instance that injects `Authorization: Bearer {token}`.
  Dio withBearerToken(String token) {
    final client = Dio(_dio.options);
    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
      ),
    );
    return client;
  }
}
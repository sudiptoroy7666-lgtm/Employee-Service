import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import 'api_config.dart';
import 'auth_interceptor.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient({required TokenStorage tokenStorage})
      : _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  ) {
    _dio.interceptors.add(AuthInterceptor(tokenStorage, _dio)); // Pass _dio here
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (obj) => debugPrint('🛰️ [API] $obj'),
    ));
    _allowSelfSignedCerts();
  }


  final Dio _dio;
  Dio get dio => _dio;

  /// ⚠️  DEV ONLY — accepts any TLS cert so the app can reach the private-IP backend.
  /// The bypass only applies in debug builds; release builds enforce real certs.
  void _allowSelfSignedCerts() {
    if (!kDebugMode) return;
    final adapter = _dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }
  }
}
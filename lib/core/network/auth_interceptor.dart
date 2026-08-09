import 'package:dio/dio.dart';
import 'dart:async';
import '../constants/api_endpoints.dart';
import 'api_config.dart';
import 'token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._dio);
  final TokenStorage _storage;
  final Dio _dio;
  bool _isRefreshing = false;
  final List<Completer<String>> _refreshSubscribers = [];
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Always attach client type
    options.headers[ApiConfig.clientTypeHeader] = ApiConfig.clientTypeValue;

    final isLogin = options.path == ApiEndpoints.login;
    final isRefresh = options.path == ApiEndpoints.refresh;

    // 1. DO NOT attach expired/fake tokens to Login or Refresh endpoints
    if (!isLogin && !isRefresh) {
      final token = await _storage.readToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    // 2. Refresh endpoint needs the refresh token, Login does not
    if (!isLogin) {
      final refresh = await _storage.readRefreshToken();
      if (refresh != null) {
        options.headers[ApiConfig.refreshTokenHeader] = refresh;
      }
    }

    handler.next(options);
  }



  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final path = err.requestOptions.path;
    if (path == ApiEndpoints.login || path == ApiEndpoints.refresh) {
      handler.next(err);
      return;
    }

    if (err.response?.statusCode == 401) {
      // 👇 RELAXED CHECK: Any 401 on a normal endpoint means token is dead
      final isTokenError = true;

      if (isTokenError && !_isRefreshing) {
        _isRefreshing = true;
        try {
          final newToken = await _refreshToken();
          _isRefreshing = false;

          for (final completer in _refreshSubscribers) {
            completer.complete(newToken); // Resolve queued requests
          }
          _refreshSubscribers.clear();

          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await _dio.fetch(err.requestOptions);
          handler.resolve(retryResponse);
          return;
        } catch (e) {
          _isRefreshing = false;
          // 👇 CRITICAL FIX: Fail all queued requests so they don't hang forever
          for (final completer in _refreshSubscribers) {
            completer.completeError(e);
          }
          _refreshSubscribers.clear();
          await _storage.clear(); // Force re-login
        }
      } else if (isTokenError) {
        final completer = Completer<String>();
        _refreshSubscribers.add(completer);

        try {
          final newToken = await completer.future;
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await _dio.fetch(err.requestOptions);
          handler.resolve(retryResponse);
          return;
        } catch (e) {
          handler.next(err); // Pass original 401 error if refresh failed
          return;
        }
      }
    }
    handler.next(err);
  }

  Future<String> _refreshToken() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null) throw Exception('No refresh token available');

    // This request will go through onRequest, but because the path is
    // ApiEndpoints.refresh, it will correctly skip the Authorization header
    // and only attach the x-refresh-token.
    final response = await _dio.post(
      ApiEndpoints.refresh,
    );

    final data = response.data as Map<String, dynamic>;
    final newToken = data['accessToken'] as String? ?? data['token'] as String?;

    if (newToken == null || newToken.isEmpty) {
      throw Exception('Refresh token response missing access token');
    }

    await _storage.write(token: newToken, refreshToken: refreshToken);
    return newToken;
  }
}
import 'package:dio/dio.dart';
import 'dart:async';
import '../constants/api_endpoints.dart';
import 'api_config.dart';
import 'token_storage.dart';
import 'dart:convert';
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._dio);
  final TokenStorage _storage;
  final Dio _dio;
  bool _isRefreshing = false;
  final List<void Function(String)> _refreshSubscribers = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers[ApiConfig.clientTypeHeader] = ApiConfig.clientTypeValue;

    final isLogin = options.path == ApiEndpoints.login;
    final isRefresh = options.path == ApiEndpoints.refresh;

    if (!isLogin && !isRefresh) {
      final token = await _storage.readToken();
      if (token != null && token.isNotEmpty) {
        // PROACTIVE REFRESH: If token expires in < 15 seconds, refresh it NOW
        if (_isTokenExpiringSoon(token) && !_isRefreshing) {
          try {
            final newToken = await _refreshToken();
            options.headers['Authorization'] = 'Bearer $newToken';
          } catch (_) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } else {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
    }

    if (!isLogin) {
      final refresh = await _storage.readRefreshToken();
      if (refresh != null) {
        options.headers[ApiConfig.refreshTokenHeader] = refresh;
      }
    }

    handler.next(options);
  }

  /// Decodes the JWT payload and checks if it expires in less than 15 seconds.
  bool _isTokenExpiringSoon(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded) as Map<String, dynamic>;
      final exp = payload['exp'] as int?;
      if (exp == null) return false;

      final expiresAt = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return expiresAt.difference(DateTime.now()).inSeconds < 15;
    } catch (_) {
      return false;
    }
  }
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 🛑 NEVER try to refresh if the Login or Refresh request itself fails
    // (e.g. wrong password, or refresh token is actually dead)
    final path = err.requestOptions.path;
    if (path == ApiEndpoints.login || path == ApiEndpoints.refresh) {
      handler.next(err);
      return;
    }

    if (err.response?.statusCode == 401) {
      final errorBody = err.response?.data;
      final isTokenError = errorBody is Map &&
          (errorBody['error']?.toString().toLowerCase().contains('token') ?? false);

      if (isTokenError && !_isRefreshing) {
        _isRefreshing = true;

        try {
          final newToken = await _refreshToken();
          _isRefreshing = false;

          for (final callback in _refreshSubscribers) {
            callback(newToken);
          }
          _refreshSubscribers.clear();

          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await _dio.fetch(err.requestOptions);
          handler.resolve(retryResponse);
          return;
        } catch (e) {
          _isRefreshing = false;
          _refreshSubscribers.clear();
          await _storage.clear(); // Force re-login
        }
      } else if (isTokenError) {
        final completer = Completer<String>();
        _refreshSubscribers.add(completer.complete);

        final newToken = await completer.future;
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final retryResponse = await _dio.fetch(err.requestOptions);
        handler.resolve(retryResponse);
        return;
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
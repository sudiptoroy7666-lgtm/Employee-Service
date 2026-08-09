import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the auth + refresh tokens between app launches.
class TokenStorage {
  TokenStorage(this._storage);
  final FlutterSecureStorage _storage;

  static const _kToken = 'auth.token';
  static const _kRefresh = 'auth.refresh';
  static const _kUserId = 'auth.userId';

  Future<String?> readToken() => _storage.read(key: _kToken);
  Future<String?> readRefreshToken() => _storage.read(key: _kRefresh);
  Future<String?> readUserId() => _storage.read(key: _kUserId);

  Future<void> write({
    required String token,
    String? refreshToken,
    String? userId,
  }) async {
    await _storage.write(key: _kToken, value: token);
    if (refreshToken != null) await _storage.write(key: _kRefresh, value: refreshToken);
    if (userId != null) await _storage.write(key: _kUserId, value: userId);
  }

  Future<void> clear() async {
    await _storage.delete(key: _kToken);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kUserId);
  }
}
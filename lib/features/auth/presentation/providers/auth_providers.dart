import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/models/employee.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/remote_auth_repository.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthenticationRepository>(
      (ref) {
    debugPrint('🔐 Auth: REMOTE');
    return RemoteAuthenticationRepository(
      ref.read(apiClientProvider),
      ref.read(tokenStorageProvider),
    );
  },
  name: 'authRepository',
);

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<Employee?>>(
      (ref) => AuthController(
    ref.read(authRepositoryProvider),
    ref.read(tokenStorageProvider), // 👈 Passed storage to constructor
  ),
  name: 'authController',
);

class AuthController extends StateNotifier<AsyncValue<Employee?>> {
  // 👇 Fixed constructor to accept both dependencies
  AuthController(this._repository, this._storage) : super(const AsyncLoading()) {
    _checkAuthStatus(); // Check tokens on startup
  }

  final AuthenticationRepository _repository;
  final TokenStorage _storage;

  bool get isAuthenticated => state.valueOrNull != null;

  Future<void> login(String idOrEmail, String password) async {
    state = const AsyncLoading();
    try {
      final employee = await _repository.login(idOrEmail, password);
      state = AsyncData(employee);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> _checkAuthStatus() async {
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) {
      state = const AsyncData(null);
      return;
    }

    try {
      final employee = await _repository.getCurrentUser()
          .timeout(const Duration(seconds: 10));
      state = AsyncData(employee);
    } on AuthFailure {
      await _storage.clear();
      state = const AsyncData(null);
    } catch (e) {
      debugPrint('⚠️ Auto-login failed (non-auth): $e');
      state = const AsyncData(null);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncData(null);
  }

  void forceLogout() {
    state = const AsyncData(null);
  }
}
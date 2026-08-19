import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/employee.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/providers/role_providers.dart'; // Added import
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

// FIX: Pass 'ref' to the controller so it can invalidate other providers
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<Employee?>>(
      (ref) => AuthController(ref.read(authRepositoryProvider), ref),
  name: 'authController',
);

class AuthController extends StateNotifier<AsyncValue<Employee?>> {
  AuthController(this._repository, this._ref) : super(const AsyncData(null));

  final AuthenticationRepository _repository;
  final Ref _ref; // Added Ref

  bool get isAuthenticated => state.valueOrNull != null;

  Future<void> login(String idOrEmail, String password) async {
    state = const AsyncLoading(); // Restored for UI spinner
    try {
      final employee = await _repository.login(idOrEmail, password);
      state = AsyncData(employee);
      _ref.invalidate(currentUserRoleProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncData(null);

    // Nuke the cached role to prevent state leak to the next user
    _ref.invalidate(currentUserRoleProvider);
  }


  void forceLogout() {
    state = const AsyncData(null);
    _ref.invalidate(currentUserRoleProvider);
  }

  void setMockEmployee(Employee employee) {
    state = AsyncData(employee);
  }
}
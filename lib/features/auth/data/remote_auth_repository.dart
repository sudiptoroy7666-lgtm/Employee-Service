import 'package:flutter/foundation.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/errors/failures.dart';
import '../../../core/models/employee.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/token_storage.dart';
import 'dto/auth_dto.dart';
import 'dto/employee_dto.dart';
import '../domain/repositories/auth_repository.dart';

class RemoteAuthenticationRepository implements AuthenticationRepository {
  RemoteAuthenticationRepository(this._client, this._storage);
  final ApiClient _client;
  final TokenStorage _storage;

  @override
  Future<Employee> login(String idOrEmail, String password) async {
    // Step 1: Login and get tokens
    final loginRes = await _client.dio.post(
      ApiEndpoints.login,
      data: {'username': idOrEmail, 'password': password},
    );

    if (loginRes.statusCode != 200 && loginRes.statusCode != 201) {
      throw const AuthFailure('Login failed. Please check your credentials.');
    }

    final loginData = loginRes.data as Map<String, dynamic>;
    final auth = LoginResponseDto.fromJson(loginData);

    if (auth.accessToken.isEmpty) {
      throw const AuthFailure('Server did not return an auth token.');
    }

    // Store tokens immediately so subsequent requests are authenticated
    await _storage.write(
      token: auth.accessToken,
      refreshToken: auth.refreshToken,
      userId: auth.id,
    );

    // Step 2: Fetch full employee profile
    final employee = await _fetchCurrentUser(auth.id);

    return employee;
  }

  @override
  Future<Employee> getCurrentUser() async {
    final userId = await _storage.readUserId();
    if (userId == null || userId.isEmpty) throw const AuthFailure('Not authenticated.');
    return _fetchCurrentUser(userId);
  }

  Future<Employee> _fetchCurrentUser(String userId) async {
    try {
      final res = await _client.dio.get(
        ApiEndpoints.employees,
        queryParameters: {'id': userId},
      );

      final body = res.data;
      if (body is Map<String, dynamic>) {
        final dto = EmployeeDto.fromJson(body);
        return Employee(
          id: dto.id,
          employeeId: dto.employeeId,
          name: dto.name,
          email: dto.email,
          phone: dto.phone,
          department: dto.department.isNotEmpty ? dto.department : 'Engineering', // fallback
          designation: dto.designation.isNotEmpty ? dto.designation : 'Employee', // fallback
          joiningDate: dto.joiningDate ?? DateTime(2020, 1, 1),
          shiftStart: dto.shiftStart,  // Pass through
          shiftEnd: dto.shiftEnd,      // Pass through
        );
      }
    } catch (e) {
      // If profile fetch fails, return minimal data from login response
      debugPrint('⚠️ Failed to fetch employee profile: $e');
    }

    // Fallback: minimal employee from login response
    return Employee(
      id: userId,
      employeeId: '',
      name: 'Employee',
      email: '',
      phone: '',
      department: '',
      designation: '',
      joiningDate: DateTime(2020, 1, 1),

    );
  }


  @override
  Future<void> logout() async {
    try {
      await _client.dio.post(ApiEndpoints.logout);
    } catch (_) {
      // ignore — even if logout fails server-side we still clear locally
    } finally {
      await _storage.clear();
    }
  }
}
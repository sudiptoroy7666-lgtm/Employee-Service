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
    debugPrint('🛰️ Attempting API Login for: $idOrEmail');
    
    final loginRes = await _client.dio.post(
      ApiEndpoints.login,
      data: {'username': idOrEmail, 'password': password},
    ).timeout(const Duration(seconds: 10));

    if (loginRes.statusCode != 200 && loginRes.statusCode != 201) {
      throw const AuthFailure('Login failed. Please check your credentials.');
    }

    final loginData = loginRes.data as Map<String, dynamic>;
    final auth = LoginResponseDto.fromJson(loginData);

    if (auth.accessToken.isEmpty) {
      throw const AuthFailure('Server did not return an auth token.');
    }

    await _storage.write(
      token: auth.accessToken,
      refreshToken: auth.refreshToken,
      userId: auth.id,
    );

    final employee = await _fetchCurrentUser(auth.id, auth);
    debugPrint('✅ API Login Successful for: ${employee.name}');
    return employee;
  }

  Future<Employee> _fetchCurrentUser(String userId, LoginResponseDto auth) async {
    try {
      final res = await _client.dio.get(
        ApiEndpoints.employees,
        queryParameters: {'id': userId},
      );

      final body = res.data;
      if (body is Map<String, dynamic>) {
        // BULLETPROOF ROLE PARSING: Handles both String and Object {"id": 8, "value": "Sales Executive"}
        String parsedRole = '';
        final rawRole = body['role'];
        if (rawRole is String) {
          parsedRole = rawRole;
        } else if (rawRole is Map<String, dynamic>) {
          parsedRole = rawRole['value']?.toString() ?? rawRole['name']?.toString() ?? '';
        }

        // Fallback to login response role if API role is empty
        if (parsedRole.isEmpty) parsedRole = auth.role;

        debugPrint('✅ Parsed Role: $parsedRole for ${body['fullName']}');

        return Employee(
          id: body['id']?.toString() ?? auth.id,
          employeeId: body['employeeId']?.toString() ?? auth.employeeId,
          name: body['fullName']?.toString() ?? auth.fullName,
          email: body['email']?.toString() ?? auth.username,
          phone: body['contact']?.toString() ?? '',
          department: body['department']?.toString() ?? 'Field',
          designation: parsedRole, // Map parsed role to designation too
          joiningDate: DateTime.tryParse(body['joiningDate']?.toString() ?? '') ?? DateTime(2020, 1, 1),
          shiftStart: body['shiftStart']?.toString(),
          shiftEnd: body['shiftEnd']?.toString(),
          role: parsedRole,
        );
      }
    } catch (e) {
      debugPrint('⚠️ Failed to fetch employee profile: $e');
    }

    // Fallback uses the rich data from the login response
    return Employee(
      id: auth.id,
      employeeId: auth.employeeId,
      name: auth.fullName,
      email: auth.username,
      phone: '',
      department: '',
      designation: auth.role,
      joiningDate: DateTime(2020, 1, 1),
      role: auth.role,
    );
  }

  @override
  Future<void> logout() async {
    try {
      await _client.dio.post(ApiEndpoints.logout);
    } catch (_) {}
    await _storage.clear();
  }
}
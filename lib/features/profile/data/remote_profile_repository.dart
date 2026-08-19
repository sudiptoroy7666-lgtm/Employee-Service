import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/models/employee.dart';
import '../../../../core/network/api_client.dart';
import '../../auth/data/dto/employee_dto.dart';
import '../domain/repositories/profile_repository.dart';

class RemoteProfileRepository implements ProfileRepository {
  RemoteProfileRepository(this._client);
  final ApiClient _client;

  @override
  Future<Employee> getProfile() async {
    final res = await _client.dio.get(ApiEndpoints.me);
    final body = res.data;
    if (body is Map<String, dynamic>) {
      final dto = EmployeeDto.fromJson(body);
      return Employee(
        id: dto.id,
        employeeId: dto.employeeId,
        name: dto.name,
        email: dto.email,
        phone: dto.phone,
        department: dto.department.isNotEmpty ? dto.department : 'Engineering',
        designation: dto.designation.isNotEmpty ? dto.designation : 'Employee',
        joiningDate: dto.joiningDate ?? DateTime(2020, 1, 1),
        shiftStart: dto.shiftStart,
        shiftEnd: dto.shiftEnd,
      );
    }
    throw const AppFailure('Could not load your profile.');
  }

  @override
  Future<void> updateProfile(Employee employee) async {
    await _client.dio.put(ApiEndpoints.me, data: {
      'fullName': employee.name,
      'email': employee.email,
      'contact': employee.phone,
    });
  }
}
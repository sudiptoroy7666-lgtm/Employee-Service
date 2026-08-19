import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/models/activity.dart';
import '../../../../core/models/employee.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/token_storage.dart';
import '../../attendance/data/dto/attendance_dto.dart';
import '../../auth/data/dto/employee_dto.dart';
import '../domain/repositories/home_repository.dart';

class RemoteHomeRepository implements HomeRepository {
  RemoteHomeRepository(this._client, this._storage);
  final ApiClient _client;
  final TokenStorage _storage;

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
  Future<List<ActivityItem>> getRecentActivities() async {
    final userId = await _storage.readUserId() ?? '';
    try {
      final res = await _client.dio.get(
        ApiEndpoints.attendanceToday,
        queryParameters: {'userId': userId},
      );
      final body = res.data;
      final dto = TodayAttendanceDto.fromJson(body is Map<String, dynamic> ? body : const {});
      final items = <ActivityItem>[];
      if (dto.checkInTime != null) {
        items.add(ActivityItem(
          id: 'act-checkin-${dto.checkInTime!.millisecondsSinceEpoch}',
          type: ActivityType.checkIn,
          title: 'Checked in',
          description: 'You checked in at work',
          occurredAt: dto.checkInTime!,
        ));
      }
      if (dto.checkOutTime != null) {
        items.add(ActivityItem(
          id: 'act-checkout-${dto.checkOutTime!.millisecondsSinceEpoch}',
          type: ActivityType.checkOut,
          title: 'Checked out',
          description: 'You checked out of work',
          occurredAt: dto.checkOutTime!,
        ));
      }
      return items;
    } catch (_) {
      // If today's status is unavailable, show no recent activity.
      return const <ActivityItem>[];
    }
  }
}
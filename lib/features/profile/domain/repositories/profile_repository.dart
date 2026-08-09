import '../../../../core/models/employee.dart';

/// Reads and updates the employee's own profile through the backend.
/// Backed by [RemoteProfileRepository].
abstract class ProfileRepository {
  Future<Employee> getProfile();
  Future<void> updateProfile(Employee employee);
}
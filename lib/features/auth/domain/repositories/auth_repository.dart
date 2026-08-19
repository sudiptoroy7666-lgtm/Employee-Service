import '../../../../core/models/employee.dart';

abstract class AuthenticationRepository {
  Future<Employee> login(String idOrEmail, String password);
  Future<void> logout();
}
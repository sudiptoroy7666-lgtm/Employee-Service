import '../../../../core/models/statement.dart';

abstract class StatementRepository {
  Future<EmployeeStatement> getStatement(DateTime month);
}
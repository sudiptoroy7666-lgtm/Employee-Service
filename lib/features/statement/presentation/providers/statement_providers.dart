import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/employee.dart';
import '../../../../core/models/statement.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../attendance/presentation/providers/attendance_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../leave/presentation/providers/leave_providers.dart';
import '../../../payments/presentation/providers/payment_providers.dart';
import '../../data/remote_statement_repository.dart';
import '../../domain/repositories/statement_repository.dart';

final statementRepositoryProvider = Provider<StatementRepository>((ref) {
  return RemoteStatementRepository(
    client: ref.read(apiClientProvider),
    storage: ref.read(tokenStorageProvider),
    attendance: ref.read(attendanceRepositoryProvider),
    leave: ref.read(leaveRepositoryProvider),
    payment: ref.read(paymentRepositoryProvider),
    employee: Future<Employee>.value(
      ref.read(authControllerProvider).valueOrNull ??
          Employee(
            id: '',
            employeeId: '',
            name: 'Employee',
            email: '',
            phone: '',
            department: '',
            designation: '',
            joiningDate: DateTime(2020, 1, 1),
          ),
    ),
  );
});

final statementProvider = FutureProvider.family.autoDispose<EmployeeStatement, DateTime>((ref, month) {
  final repo = ref.watch(statementRepositoryProvider);
  return repo.getStatement(month);
}, name: 'statement');
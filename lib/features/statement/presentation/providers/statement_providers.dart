import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/employee.dart';
import '../../../../core/models/statement.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../attendance/data/remote_attendance_repository.dart';
import '../../../attendance/presentation/providers/attendance_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../leave/data/remote_leave_repository.dart';
import '../../../leave/presentation/providers/leave_providers.dart';
import '../../../payments/data/remote_payment_repository.dart';
import '../../../payments/presentation/providers/payment_providers.dart';
import '../../data/remote_statement_repository.dart';
import '../../domain/repositories/statement_repository.dart';

final statementRepositoryProvider = Provider<StatementRepository>((ref) {
  return RemoteStatementRepository(
    client: ref.read(apiClientProvider),
    storage: ref.read(tokenStorageProvider),
    attendance: ref.read(attendanceRepositoryProvider) as RemoteAttendanceRepository,
    leave: ref.read(leaveRepositoryProvider) as RemoteLeaveRepository,
    payment: ref.read(paymentRepositoryProvider) as RemotePaymentRepository,
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
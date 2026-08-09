import 'package:flutter/foundation.dart';

import '../../../../core/models/attendance.dart';
import '../../../../core/models/employee.dart';
import '../../../../core/models/leave.dart';
import '../../../../core/models/payment.dart';
import '../../../../core/models/statement.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/token_storage.dart';
import '../../attendance/domain/repositories/attendance_repository.dart';
import '../../leave/domain/repositories/leave_repository.dart';
import '../../payments/domain/repositories/payment_repository.dart';
import '../domain/repositories/statement_repository.dart';

/// The swagger doesn't define a dedicated statement endpoint that matches our UI,
/// but /api/attendance/statement exists. We compose from report + balances + payroll
/// so every section renders even if the backend omits a field.
class RemoteStatementRepository implements StatementRepository {
  RemoteStatementRepository({
    required this.client,
    required this.storage,
    required this.attendance,
    required this.leave,
    required this.payment,
    required this.employee,
  });

  final ApiClient client;
  final TokenStorage storage;
  final AttendanceRepository attendance;
  final LeaveRepository leave;
  final PaymentRepository payment;
  final Future<Employee> employee;

  @override
  Future<EmployeeStatement> getStatement(DateTime month) async {
    // 🛡️ FAULT-TOLERANCE WRAPPER
    // If one API fails (like the broken attendance report), we catch it
    // and return null so the rest of the statement can still load.
    Future<T?> safeFetch<T>(Future<T> future) async {
      try {
        return await future;
      } catch (e) {
        debugPrint('⚠️ Statement fetch failed for $T: $e');
        return null;
      }
    }

    final results = await Future.wait([
      safeFetch(attendance.getMonthAttendance(month)),
      safeFetch(leave.getBalances()),
      safeFetch(payment.getPayments()),
      employee, // This won't fail as it's just a Future.value
    ]);

    final ma = results[0] as MonthAttendance?;
    final balances = results[1] as List<dynamic>?;
    final payments = results[2] as List<dynamic>?;
    final emp = results[3] as Employee;

    // 📊 1. Attendance Fallback (If 500 error, show 0s)
    final attSummary = ma?.summary ?? const AttendanceSummary(
      workingDays: 0,
      present: 0,
      late: 0,
      absent: 0,
      leaveDays: 0,
    );
    final records = ma?.records ?? [];

    // 💰 2. Payment Match
    final bill = payments?.cast<dynamic>().where((p) =>
    (p as PaymentBill).paymentMonth.year == month.year &&
        p.paymentMonth.month == month.month
    ).firstOrNull as PaymentBill?;

    // ⏱️ 3. Work Summary Calculation
    final totalMinutes = records.fold<int>(0, (s, r) => s + (r.totalWorkingMinutes));
    final overtime = records.fold<int>(0, (s, r) => s + r.overtimeMinutes);

    // 🏖️ 4. Leave Balance Fallback
    final annual = balances?.cast<dynamic>().firstWhere(
          (b) => (b as LeaveBalance).type == LeaveType.annual,
      orElse: () => null,
    ) as LeaveBalance?;

    return EmployeeStatement(
      employee: emp,
      month: month,
      attendance: attSummary,
      work: WorkSummary(
          regularMinutes: totalMinutes - overtime,
          overtimeMinutes: overtime
      ),
      leave: LeaveSummary(
        usedDays: attSummary.leaveDays,
        remainingDays: annual?.remainingDays ?? 0,
      ),
      payment: bill == null
          ? null
          : PaymentSummary(
        grossPay: bill.grossAmount,
        deductions: (bill.deductions ?? 0) + (bill.tax ?? 0),
        netPay: bill.netAmount,
        currency: bill.currency,
        status: bill.status,
      ),
    );
  }
}
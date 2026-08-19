import 'package:flutter/foundation.dart';
import '../../../../core/models/attendance.dart';
import '../../../../core/models/employee.dart';
import '../../../../core/models/payment.dart';
import '../../../../core/models/statement.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/token_storage.dart';
import '../../attendance/data/remote_attendance_repository.dart';
import '../../leave/data/remote_leave_repository.dart';
import '../../payments/data/remote_payment_repository.dart';
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
  final RemoteAttendanceRepository attendance;
  final RemoteLeaveRepository leave;
  final RemotePaymentRepository payment;
  final Future<Employee> employee;

  @override
  Future<EmployeeStatement> getStatement(DateTime month) async {
    Employee emp;
    try {
      emp = await employee;
    } catch (_) {
      emp = Employee(
        id: '',
        employeeId: '',
        name: 'Employee',
        email: '',
        phone: '',
        department: '',
        designation: '',
        joiningDate: DateTime.now(),
      );
    }

    dynamic ma;
    try {
      ma = await attendance.getMonthAttendance(month);
    } catch (e) {
      debugPrint('Statement: attendance fetch failed: $e');
      ma = null;
    }

    List balances = [];
    try {
      balances = await leave.getBalances();
    } catch (e) {
      debugPrint('Statement: leave fetch failed: $e');
    }

    List payments = [];
    try {
      payments = await payment.getPayments();
    } catch (e) {
      debugPrint('Statement: payment fetch failed: $e');
    }

    final bill = payments.isNotEmpty
        ? payments
            .cast<dynamic>()
            .where((p) =>
                (p as dynamic).paymentMonth.year == month.year &&
                p.paymentMonth.month == month.month)
            .firstOrNull
        : null;

    final totalMinutes = ma != null
        ? (ma.records as List).fold<int>(
            0, (s, r) => s + ((r as dynamic).totalWorkingMinutes as int? ?? 0))
        : 0;
    final overtime = ma != null
        ? (ma.records as List)
            .fold<int>(0, (s, r) => s + ((r as dynamic).overtimeMinutes as int? ?? 0))
        : 0;

    final annual = balances.isNotEmpty
        ? balances.cast<dynamic>().firstWhere(
              (b) => (b as dynamic).type.toString().toLowerCase().contains('annual'),
              orElse: () => null,
            )
        : null;

    return EmployeeStatement(
      employee: emp,
      month: month,
      attendance: ma != null
          ? ma.summary
          : const AttendanceSummary(
              workingDays: 0, present: 0, late: 0, absent: 0),
      work: WorkSummary(
        regularMinutes: totalMinutes - overtime,
        overtimeMinutes: overtime,
      ),
      leave: LeaveSummary(
        usedDays: ma != null ? (ma.summary as dynamic).leaveDays ?? 0 : 0,
        remainingDays: annual != null ? (annual.remainingDays as int) : 0,
      ),
      payment: bill == null
          ? null
          : PaymentSummary(
              grossPay: (bill as dynamic).grossAmount ?? 0,
              deductions:
                  ((bill.deductions ?? 0) + (bill.tax ?? 0)) as double,
              netPay: bill.netAmount ?? 0,
              currency: bill.currency ?? 'BDT',
              status: bill.status ?? PaymentStatus.pending,
            ),
    );
  }
}
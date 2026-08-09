import 'attendance.dart';
import 'employee.dart';
import 'payment.dart';

class WorkSummary {
  const WorkSummary({required this.regularMinutes, required this.overtimeMinutes});
  final int regularMinutes;
  final int overtimeMinutes;
  int get totalMinutes => regularMinutes + overtimeMinutes;
}

class LeaveSummary {
  const LeaveSummary({required this.usedDays, required this.remainingDays});
  final int usedDays;
  final int remainingDays;
}

class PaymentSummary {
  const PaymentSummary({
    required this.grossPay,
    required this.deductions,
    required this.netPay,
    required this.currency,
    required this.status,
  });
  final double grossPay;
  final double deductions;
  final double netPay;
  final String currency;
  final PaymentStatus status;
}

class EmployeeStatement {
  const EmployeeStatement({
    required this.employee,
    required this.month,
    required this.attendance,
    required this.leave,
    this.work,
    this.payment,
  });

  final Employee employee;
  final DateTime month;
  final AttendanceSummary attendance;
  final WorkSummary? work;
  final LeaveSummary leave;
  final PaymentSummary? payment;
}
enum PaymentStatus { paid, pending, processing, failed }

extension PaymentStatusLabel on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.failed:
        return 'Failed';
    }
  }
}

class PaymentBill {
  const PaymentBill({
    required this.id,
    required this.employeeId,
    required this.paymentMonth,
    required this.currency,
    required this.grossAmount,
    required this.netAmount,
    required this.status,
    this.allowances,
    this.bonuses,
    this.deductions,
    this.tax,
    this.paymentDate,
    this.referenceId,
    this.notes,
  });

  final String id;
  final String employeeId;
  final DateTime paymentMonth;
  final String currency;
  final double grossAmount;
  final double? allowances;
  final double? bonuses;
  final double? deductions;
  final double? tax;
  final double netAmount;
  final PaymentStatus status;
  final DateTime? paymentDate;
  final String? referenceId;
  final String? notes;
}
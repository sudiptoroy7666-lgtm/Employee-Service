class Commission {
  final String id;
  final String month;
  final double totalSales;
  final double commissionRate;
  final double commissionAmount;
  final CommissionStatus status;

  Commission({
    required this.id,
    required this.month,
    required this.totalSales,
    required this.commissionRate,
    required this.commissionAmount,
    required this.status,
  });
}

enum CommissionStatus {
  pending,
  paid;

  String get label {
    switch (this) {
      case CommissionStatus.pending:
        return 'Pending';
      case CommissionStatus.paid:
        return 'Paid';
    }
  }
}

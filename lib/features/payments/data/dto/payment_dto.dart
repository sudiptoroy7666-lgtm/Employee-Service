class PaymentBillDto {
  PaymentBillDto.fromJson(Map<String, dynamic> j)
      : id = (j['id'] ?? j['_id'])?.toString() ?? '',
        month = (j['month'] ?? 0).toInt(),  // Numeric month (1-12)
        year = (j['year'] ?? 0).toInt(),
        grossAmount = double.tryParse(j['baseSalary']?.toString() ?? '0') ?? 0,
        netAmount = double.tryParse(j['amount']?.toString() ?? '0') ?? 0,
        overtimePay = double.tryParse(j['overtimePay']?.toString() ?? '0') ?? 0,
        unpaidDeduction = double.tryParse(j['unpaidDeduction']?.toString() ?? '0') ?? 0,
        status = (j['status']?['value'] ?? 'Pending').toString(),
        paymentDate = j['createdAt'] != null
            ? DateTime.tryParse(j['createdAt'].toString())
            : null;

  final String id;
  final int month;
  final int year;
  final double grossAmount;
  final double netAmount;
  final double overtimePay;
  final double unpaidDeduction;
  final String status;
  final DateTime? paymentDate;
}
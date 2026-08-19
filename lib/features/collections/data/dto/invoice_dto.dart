class InvoiceDto {
  InvoiceDto.fromJson(Map<String, dynamic> j)
      : id = j['id']?.toString() ?? '',
        clientName = j['stakeholder']?['name']?.toString() ?? 'Unknown Client',
        totalAmount = double.tryParse(j['totalAmount']?.toString() ?? '0') ?? 0.0,
        paidAmount = double.tryParse(j['paidAmount']?.toString() ?? '0') ?? 0.0,
        date = DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now();

  final String id;
  final String clientName;
  final double totalAmount;
  final double paidAmount;
  final DateTime date;

  double get dueAmount => totalAmount - paidAmount;
}

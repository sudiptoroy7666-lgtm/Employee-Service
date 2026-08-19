enum CollectionSyncStatus { synced, pending, failed }

class Collection {
  final String id;
  final String invoiceId;
  final String clientName;
  final double amount;
  final double totalAmount;
  final double paidAmount;
  final String orderType;
  final String orderNumber;
  final DateTime collectionDate;
  final String paymentMethod;
  final int paymentMethodId;
  final String referenceNumber;
  final String notes;
  final List<String> imageUrls;
  final bool isLocalOnly;
  final CollectionSyncStatus syncStatus;

  Collection({
    required this.id,
    required this.invoiceId,
    required this.clientName,
    required this.amount,
    this.totalAmount = 0,
    this.paidAmount = 0,
    this.orderType = 'bulk',
    this.orderNumber = '',
    required this.collectionDate,
    required this.paymentMethod,
    this.paymentMethodId = 0,
    required this.referenceNumber,
    this.notes = '',
    this.imageUrls = const [],
    this.isLocalOnly = false,
    this.syncStatus = CollectionSyncStatus.synced,
  });

  double get dueAmount => totalAmount - paidAmount;

  bool get isFullyPaid => dueAmount <= 0;

  Collection copyWith({
    String? id,
    String? invoiceId,
    String? clientName,
    double? amount,
    double? totalAmount,
    double? paidAmount,
    String? orderType,
    String? orderNumber,
    DateTime? collectionDate,
    String? paymentMethod,
    int? paymentMethodId,
    String? referenceNumber,
    String? notes,
    List<String>? imageUrls,
    bool? isLocalOnly,
    CollectionSyncStatus? syncStatus,
  }) {
    return Collection(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      clientName: clientName ?? this.clientName,
      amount: amount ?? this.amount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      orderType: orderType ?? this.orderType,
      orderNumber: orderNumber ?? this.orderNumber,
      collectionDate: collectionDate ?? this.collectionDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      imageUrls: imageUrls ?? this.imageUrls,
      isLocalOnly: isLocalOnly ?? this.isLocalOnly,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

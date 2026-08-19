enum PromotionSyncStatus { synced, pending, failed }

class Promotion {
  final String id;
  final String productName;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final double discountPercent;
  final String targetClients;
  
  // New fields for marketing tracking
  final String productId;
  final int estimatedDemand;
  final String? competitorProductName;
  final double? competitorPrice;
  final String? competitorNotes;
  final bool isLocalOnly;
  final PromotionSyncStatus syncStatus;

  Promotion({
    required this.id,
    required this.productName,
    this.description = '',
    DateTime? startDate,
    DateTime? endDate,
    this.discountPercent = 0.0,
    this.targetClients = '',
    required this.productId,
    required this.estimatedDemand,
    this.competitorProductName,
    this.competitorPrice,
    this.competitorNotes,
    this.isLocalOnly = false,
    this.syncStatus = PromotionSyncStatus.synced,
  }) : 
    startDate = startDate ?? DateTime.now(),
    endDate = endDate ?? DateTime.now();

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  Promotion copyWith({
    String? id,
    String? productName,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? discountPercent,
    String? targetClients,
    String? productId,
    int? estimatedDemand,
    String? competitorProductName,
    double? competitorPrice,
    String? competitorNotes,
    bool? isLocalOnly,
    PromotionSyncStatus? syncStatus,
  }) {
    return Promotion(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      discountPercent: discountPercent ?? this.discountPercent,
      targetClients: targetClients ?? this.targetClients,
      productId: productId ?? this.productId,
      estimatedDemand: estimatedDemand ?? this.estimatedDemand,
      competitorProductName: competitorProductName ?? this.competitorProductName,
      competitorPrice: competitorPrice ?? this.competitorPrice,
      competitorNotes: competitorNotes ?? this.competitorNotes,
      isLocalOnly: isLocalOnly ?? this.isLocalOnly,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

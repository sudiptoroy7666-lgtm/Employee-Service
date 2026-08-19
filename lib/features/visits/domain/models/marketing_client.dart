import 'client.dart';

class MarketingClient {
  final String id;
  final String stakeholderId;
  final String name;
  final String? companyName;
  final ClientType type;
  final String contact;
  final String? email;
  final String? address;
  final String? country;
  final double commissionPercentage;
  final bool bulkOrderAllowed;
  final List<String> allowedProductIds;
  final bool isActive;

  const MarketingClient({
    required this.id,
    this.stakeholderId = '',
    required this.name,
    this.companyName,
    required this.type,
    this.contact = '',
    this.email,
    this.address,
    this.country,
    this.commissionPercentage = 0.0,
    this.bulkOrderAllowed = true,
    this.allowedProductIds = const [],
    this.isActive = true,
  });

  String get displayName => companyName?.isNotEmpty == true ? companyName! : name;

  String get typeLabel {
    switch (type) {
      case ClientType.dealer:
        return 'Dealer';
      case ClientType.retailer:
        return 'Retailer';
      case ClientType.farmer:
        return 'Farmer';
    }
  }

  MarketingClient copyWith({
    String? id,
    String? stakeholderId,
    String? name,
    String? companyName,
    ClientType? type,
    String? contact,
    String? email,
    String? address,
    String? country,
    double? commissionPercentage,
    bool? bulkOrderAllowed,
    List<String>? allowedProductIds,
    bool? isActive,
  }) {
    return MarketingClient(
      id: id ?? this.id,
      stakeholderId: stakeholderId ?? this.stakeholderId,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      type: type ?? this.type,
      contact: contact ?? this.contact,
      email: email ?? this.email,
      address: address ?? this.address,
      country: country ?? this.country,
      commissionPercentage: commissionPercentage ?? this.commissionPercentage,
      bulkOrderAllowed: bulkOrderAllowed ?? this.bulkOrderAllowed,
      allowedProductIds: allowedProductIds ?? this.allowedProductIds,
      isActive: isActive ?? this.isActive,
    );
  }
}

import 'visit_type.dart';
import 'client.dart';
import 'visit_status.dart';

enum VisitSyncStatus { synced, pending, failed }

class Visit {
  final String id;
  final String clientName;
  final String clientId;
  final ClientType clientType;
  final VisitType visitType;
  final DateTime scheduledTime;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final VisitStatus status;
  final String notes;
  final VisitLocation location;
  
  // New fields for marketing tracking
  final String? feedback;
  final String? estimatedDemand;
  final List<String> productIds;
  final List<String> imagePaths;
  final bool isLocalOnly;
  final VisitSyncStatus syncStatus;

  Visit({
    required this.id,
    required this.clientName,
    required this.clientId,
    required this.clientType,
    required this.visitType,
    required this.scheduledTime,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.notes = '',
    required this.location,
    this.feedback,
    this.estimatedDemand,
    this.productIds = const [],
    this.imagePaths = const [],
    this.isLocalOnly = false,
    this.syncStatus = VisitSyncStatus.synced,
  });

  Visit copyWith({
    String? id,
    String? clientName,
    String? clientId,
    ClientType? clientType,
    VisitType? visitType,
    DateTime? scheduledTime,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    VisitStatus? status,
    String? notes,
    VisitLocation? location,
    String? feedback,
    String? estimatedDemand,
    List<String>? productIds,
    List<String>? imagePaths,
    bool? isLocalOnly,
    VisitSyncStatus? syncStatus,
  }) {
    return Visit(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      clientId: clientId ?? this.clientId,
      clientType: clientType ?? this.clientType,
      visitType: visitType ?? this.visitType,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      feedback: feedback ?? this.feedback,
      estimatedDemand: estimatedDemand ?? this.estimatedDemand,
      productIds: productIds ?? this.productIds,
      imagePaths: imagePaths ?? this.imagePaths,
      isLocalOnly: isLocalOnly ?? this.isLocalOnly,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

class VisitLocation {
  final double latitude;
  final double longitude;
  final String address;

  VisitLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
  
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
  };

  factory VisitLocation.fromJson(Map<String, dynamic> json) => VisitLocation(
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    address: json['address'] as String? ?? '',
  );
}

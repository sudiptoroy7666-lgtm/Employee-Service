import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../domain/models/visit.dart';
import '../domain/models/visit_status.dart';
import '../domain/models/visit_type.dart';
import '../domain/models/client.dart';
import '../domain/repositories/visit_repository.dart';

class RemoteVisitRepository implements VisitRepository {
  final ApiClient _client;

  RemoteVisitRepository(this._client);


  @override
  Future<Visit?> getVisitById(String id) async {
    final visits = await getVisits();
    return visits.where((v) => v.id == id).firstOrNull;
  }

  @override
  Future<List<Visit>> getVisits({
    String? userId,
    int? typeId,
    int? statusId,
    String? startDate,
    String? endDate,
  }) async {
    final res = await _client.dio.get('/api/visit/');
    final list = res.data is List ? res.data as List : (res.data['data'] as List? ?? []);

    return list.map((json) {
      return Visit(
        id: json['id']?.toString() ?? '',
        clientName: json['contactName']?.toString() ?? json['stakeholder']?['name']?.toString() ?? 'Unknown',
        clientId: json['stakeholderId']?.toString() ?? '',
        clientType: ClientType.dealer,
        // Fix: Safely parse typeId whether it comes as string or int
        visitType: VisitType.values.firstWhere(
                (e) => e.name == json['typeId']?.toString() || e.name.toLowerCase() == json['type']?.toString().toLowerCase(),
            orElse: () => VisitType.followUp
        ),
        scheduledTime: DateTime.tryParse(json['plannedDate']?.toString() ?? '') ?? DateTime.now(),
        checkInTime: json['checkInTime'] != null ? DateTime.tryParse(json['checkInTime'].toString()) : null,
        checkOutTime: json['checkOutTime'] != null ? DateTime.tryParse(json['checkOutTime'].toString()) : null,
        status: VisitStatus.pending, // Default to pending instead of completed
        notes: json['notes']?.toString() ?? '',
        location: VisitLocation(latitude: 0, longitude: 0, address: ''),
        productIds: [],
        estimatedDemand: null,
      );
    }).toList();
  }
  @override
  Future<Visit> cancelVisit(String visitId) async {
    try {
      await _client.dio.patch('${ApiEndpoints.visitCancel}/$visitId/cancel');
      final visit = await getVisitById(visitId);
      if (visit == null) throw const AppFailure('Visit not found after cancellation.');
      return visit.copyWith(status: VisitStatus.cancelled);
    } on DioException catch (e) {
      final errorBody = e.response?.data;
      if (errorBody is Map && errorBody['error'] != null) {
        throw AppFailure(errorBody['error'].toString());
      }
      throw const AppFailure('Failed to cancel visit.');
    }
  }
  @override
  Future<Visit> createVisit(Visit visit, {String? assignedToId}) async {
    try {
      final payload = <String, dynamic>{
        'typeId': _visitTypeToId(visit.visitType), // FIX: Use integer ID
        'contactName': visit.clientName,
        'contactPhone': '',
        'plannedDate': visit.scheduledTime.toIso8601String(),
        'status': 'pending',
      };

      if (assignedToId != null && assignedToId.isNotEmpty) {
        payload['assignedToId'] = int.tryParse(assignedToId) ?? assignedToId;
      }

      if (visit.clientId.isNotEmpty) {
        payload['stakeholderId'] = int.tryParse(visit.clientId) ?? visit.clientId; // FIX: Cast to int
      }

      debugPrint('📤 createVisit payload: $payload');
      final res = await _client.dio.post(ApiEndpoints.visits, data: payload);

      debugPrint('✅ createVisit response: ${res.statusCode}');

      final data = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : {};

      return visit.copyWith(
        id: data['id']?.toString() ?? visit.id,
        syncStatus: VisitSyncStatus.synced,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorBody = e.response?.data;

      debugPrint('❌ createVisit failed: status=$statusCode, body=$errorBody');

      if (errorBody is Map && errorBody['error'] != null) {
        throw AppFailure(errorBody['error'].toString());
      }

      if (statusCode == 500) {
        throw const AppFailure('Server error. The backend might be missing required fields like assignedToId.');
      }

      throw const AppFailure('Failed to create visit. Please try again.');
    }
  }

  @override
  Future<Visit> checkInVisit(String visitId) async {
    await _client.dio.patch('/api/visit/$visitId/check-in', data: {
      'checkInTime': DateTime.now().toIso8601String(),
    });
    
    final visit = await getVisitById(visitId);
    if (visit == null) throw Exception('Visit not found after check-in');
    return visit;
  }

  @override
  Future<Visit> checkOutVisit(String visitId, {String? notes, List<String>? imagePaths}) async {
    await _client.dio.patch('/api/visit/$visitId/check-out', data: {
      'checkOutTime': DateTime.now().toIso8601String(),
      'notes': notes,
    });
    
    final visit = await getVisitById(visitId);
    if (visit == null) throw Exception('Visit not found after check-out');
    return visit;
  }

  int _visitTypeToId(VisitType type) {
    return switch (type) {
      VisitType.newLead => 1,
      VisitType.followUp => 2,
      VisitType.promotion => 3,
      VisitType.collection => 4,
    };
  }
}

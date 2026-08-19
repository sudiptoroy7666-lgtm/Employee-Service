import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/api_utils.dart';
import '../../../../core/errors/failures.dart';
import '../domain/models/complaint.dart';
import '../domain/repositories/complaint_repository.dart';

class RemoteComplaintRepository implements ComplaintRepository {
  final ApiClient _client;

  RemoteComplaintRepository(this._client);

  @override
  Future<List<Complaint>> getComplaints() async {
    try {
      final res = await _client.dio.get(ApiEndpoints.marketUpdates);
      final list = extractList(res.data);

      return list
          .where((j) =>
              ((j as Map<String, dynamic>)['notes']?.toString() ?? '')
                  .startsWith('[COMPLAINT]'))
          .map((j) {
        final json = j as Map<String, dynamic>;
        final notes = json['notes']?.toString() ?? '';
        final lines = notes.split('\n');

        return Complaint(
          id: json['id']?.toString() ?? '',
          clientName: lines.length > 2
              ? lines[2].replaceAll('Client: ', '')
              : 'Unknown',
          subject: lines.isNotEmpty
              ? lines[0].replaceAll('[COMPLAINT] ', '')
              : 'No Subject',
          description: lines.length > 1 ? lines[1] : '',
          submittedDate: DateTime.tryParse(json['date']?.toString() ?? '') ??
              DateTime.now(),
          status: ComplaintStatus.open,
          priority: ComplaintPriority.medium,
        );
      }).toList();
    } on DioException catch (e) {
      debugPrint('getComplaints failed: ${e.response?.statusCode}');
      return [];
    }
  }

  @override
  Future<Complaint> createComplaint(Complaint complaint) async {
    try {
      await _client.dio.post(ApiEndpoints.marketUpdates, data: {
        'seedTypeId': 36, // FIX: Use a valid known ID instead of 1
        'regionId': 1,
        'pricePerKg': 100.0, // FIX: Backend rejects 0, use 100.0
        'date': DateTime.now().toIso8601String(),
        'notes': '[COMPLAINT] ${complaint.subject}\n${complaint.description}\nClient: ${complaint.clientName}',
      });
      return complaint;
    } on DioException catch (e) {
      final errorBody = e.response?.data;
      debugPrint('❌ Complaint failed: ${e.response?.statusCode}, body: $errorBody');
      if (errorBody is Map && errorBody['error'] != null) {
        throw AppFailure(errorBody['error'].toString());
      }
      throw const AppFailure('Failed to submit complaint.');
    }
  }
}

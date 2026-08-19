import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/api_utils.dart';
import '../domain/models/followup.dart';
import '../domain/repositories/followup_repository.dart';

class RemoteFollowUpRepository implements FollowUpRepository {
  final ApiClient _client;

  RemoteFollowUpRepository(this._client);

  @override
  Future<List<FollowUp>> getFollowUps({String? leadId, int? outcomeId}) async {
    final queryParams = <String, dynamic>{};
    if (leadId != null) queryParams['leadId'] = leadId;
    if (outcomeId != null) queryParams['outcomeId'] = outcomeId;

    final res = await _client.dio.get(
      ApiEndpoints.followUps,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final list = extractList(res.data);

    return list.map((j) {
      final json = j as Map<String, dynamic>;
      return FollowUp(
        id: json['id']?.toString() ?? '',
        leadId: json['leadId']?.toString() ?? '',
        leadName: json['lead']?['name']?.toString(),
        followUpDate: DateTime.tryParse(json['followUpDate']?.toString() ?? '') ?? DateTime.now(),
        notes: json['notes']?.toString(),
        outcome: _mapOutcome(json['outcomeId']?.toString() ?? ''),
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<FollowUp> createFollowUp(FollowUp followUp) async {
    final res = await _client.dio.post(ApiEndpoints.followUps, data: {
      'leadId': followUp.leadId,
      'followUpDate': followUp.followUpDate.toIso8601String(),
      if (followUp.notes != null) 'notes': followUp.notes,
      if (followUp.outcome != null) 'outcomeId': followUp.outcome!.index + 1,
    });

    final data = res.data is Map<String, dynamic> ? res.data as Map<String, dynamic> : {};

    return followUp.copyWith(
      id: data['id']?.toString() ?? followUp.id,
      syncStatus: FollowUpSyncStatus.synced,
    );
  }

  FollowUpOutcome? _mapOutcome(String raw) {
    if (raw.isEmpty) return null;
    final id = int.tryParse(raw);
    if (id == null) return null;
    if (id >= 1 && id <= FollowUpOutcome.values.length) {
      return FollowUpOutcome.values[id - 1];
    }
    return null;
  }
}

import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/api_utils.dart';
import '../domain/models/lead.dart';
import '../domain/repositories/lead_repository.dart';

class RemoteLeadRepository implements LeadRepository {
  final ApiClient _client;

  RemoteLeadRepository(this._client);

  @override
  Future<List<Lead>> getLeads({int? statusId, int? sourceId, String? search}) async {
    final queryParams = <String, dynamic>{};
    if (statusId != null) queryParams['statusId'] = statusId;
    if (sourceId != null) queryParams['sourceId'] = sourceId;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final res = await _client.dio.get(
      ApiEndpoints.leads,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final list = extractList(res.data);

    return list.map((j) {
      final json = j as Map<String, dynamic>;
      return Lead(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        contact: json['contact']?.toString() ?? '',
        company: json['company']?.toString(),
        seedInterestId: json['seedInterestId'] != null
            ? int.tryParse(json['seedInterestId'].toString())
            : null,
        seedInterestName: json['seedInterest']?['value']?.toString(),
        sourceId: json['sourceId'] != null
            ? int.tryParse(json['sourceId'].toString())
            : null,
        sourceName: json['source']?['name']?.toString(),
        status: _mapStatus(json['status']?.toString() ?? ''),
        notes: json['notes']?.toString(),
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'].toString())
            : null,
      );
    }).toList();
  }

  @override
  Future<Lead> createLead(Lead lead) async {
    final res = await _client.dio.post(ApiEndpoints.leads, data: {
      'name': lead.name,
      'contact': lead.contact,
      if (lead.company != null) 'company': lead.company,
      if (lead.seedInterestId != null) 'seedInterestId': lead.seedInterestId,
      if (lead.sourceId != null) 'sourceId': lead.sourceId,
      if (lead.notes != null) 'notes': lead.notes,
    });

    final data = res.data is Map<String, dynamic> ? res.data as Map<String, dynamic> : {};

    return lead.copyWith(
      id: data['id']?.toString() ?? lead.id,
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      syncStatus: LeadSyncStatus.synced,
    );
  }

  @override
  Future<Lead> updateLead(Lead lead) async {
    await _client.dio.put('${ApiEndpoints.leads}${lead.id}', data: {
      'name': lead.name,
      'contact': lead.contact,
      if (lead.company != null) 'company': lead.company,
      if (lead.seedInterestId != null) 'seedInterestId': lead.seedInterestId,
      if (lead.sourceId != null) 'sourceId': lead.sourceId,
      'statusId': lead.status.index + 1,
      if (lead.notes != null) 'notes': lead.notes,
    });

    return lead.copyWith(
      updatedAt: DateTime.now(),
      syncStatus: LeadSyncStatus.synced,
    );
  }

  LeadStatus _mapStatus(String raw) {
    final s = raw.toLowerCase();
    if (s.contains('contact')) return LeadStatus.contacted;
    if (s.contains('qualif')) return LeadStatus.qualified;
    if (s.contains('convert')) return LeadStatus.converted;
    if (s.contains('lost')) return LeadStatus.lost;
    return LeadStatus.newLead;
  }
}

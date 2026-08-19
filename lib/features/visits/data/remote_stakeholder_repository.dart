import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/api_utils.dart';
import '../domain/models/marketing_client.dart';
import '../domain/models/client.dart';
import '../domain/repositories/stakeholder_repository.dart';

class RemoteStakeholderRepository implements StakeholderRepository {
  final ApiClient _client;

  RemoteStakeholderRepository(this._client);

  @override
  Future<List<MarketingClient>> getStakeholders({
    int? typeId,
    String? search,
    int page = 1,
    int limit = 100,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (typeId != null) queryParams['stakeholderTypeId'] = typeId.toString();
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final res = await _client.dio.get(
      ApiEndpoints.stakeholders,
      queryParameters: queryParams,
    );

    final list = extractList(res.data);

    return list.map((j) {
      final json = j as Map<String, dynamic>;
      return MarketingClient(
        id: json['id']?.toString() ?? '',
        stakeholderId: json['stakeholderId']?.toString() ?? '',
        name: json['name']?.toString() ?? json['companyName']?.toString() ?? 'Unknown',
        companyName: json['companyName']?.toString(),
        type: _mapClientType(json['stakeholderTypeId']?.toString() ?? '',
            json['stakeholderType']?['value']?.toString() ?? ''),
        contact: json['contact']?.toString() ?? '',
        email: json['email']?.toString(),
        address: json['address']?.toString(),
        country: json['country']?.toString(),
        commissionPercentage: double.tryParse(
                json['commissionPercentage']?.toString() ?? '0') ??
            0.0,
        bulkOrderAllowed: _isBulkAllowed(json['stakeholderTypeId']?.toString() ?? ''),
        allowedProductIds: const [],
        isActive: json['isActive'] as bool? ?? true,
      );
    }).toList();
  }

  @override
  Future<List<MarketingClient>> getStakeholdersByType(int typeId) async {
    final res = await _client.dio.get(
      '${ApiEndpoints.stakeholderByType}/$typeId',
    );

    final list = extractList(res.data);

    return list.map((j) {
      final json = j as Map<String, dynamic>;
      return MarketingClient(
        id: json['id']?.toString() ?? '',
        stakeholderId: json['stakeholderId']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        companyName: json['companyName']?.toString(),
        type: _mapClientType(typeId.toString(), ''),
        contact: json['contact']?.toString() ?? '',
        commissionPercentage: double.tryParse(
                json['commissionPercentage']?.toString() ?? '0') ??
            0.0,
        bulkOrderAllowed: _isBulkAllowed(typeId.toString()),
        allowedProductIds: const [],
        isActive: true,
      );
    }).toList();
  }

  @override
  Future<MarketingClient?> getStakeholderById(String id) async {
    final stakeholders = await getStakeholders();
    return stakeholders.where((s) => s.id == id).firstOrNull;
  }

  ClientType _mapClientType(String typeId, String typeValue) {
    final val = typeValue.toLowerCase();
    if (val.contains('farmer') || typeId == '29') return ClientType.farmer;
    if (val.contains('retailer')) return ClientType.retailer;
    return ClientType.dealer;
  }

  bool _isBulkAllowed(String typeId) {
    return typeId != '29';
  }
}

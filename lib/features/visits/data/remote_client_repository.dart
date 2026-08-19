import '../../../../core/network/api_client.dart';
import '../domain/models/marketing_client.dart';
import '../domain/models/client.dart';
import '../domain/repositories/client_repository.dart';

class RemoteClientRepository implements ClientRepository {
  final ApiClient _client;

  RemoteClientRepository(this._client);

  @override
  Future<List<MarketingClient>> getClients() async {
    final res = await _client.dio.get('/api/stakeholders/');
    final list = res.data is List ? res.data as List : (res.data['data'] as List? ?? []);
    
    return list.map((json) => MarketingClient(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['companyName']?.toString() ?? 'Unknown',
      type: ClientType.dealer, 
      bulkOrderAllowed: true,
      allowedProductIds: [], 
    )).toList();
  }

  @override
  Future<MarketingClient?> getClientById(String id) async {
    final clients = await getClients();
    return clients.where((c) => c.id == id).firstOrNull;
  }
}

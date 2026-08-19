import '../models/marketing_client.dart';

abstract class ClientRepository {
  Future<List<MarketingClient>> getClients();
  Future<MarketingClient?> getClientById(String id);
}

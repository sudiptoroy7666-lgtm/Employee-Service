import '../models/marketing_client.dart';

abstract class StakeholderRepository {
  Future<List<MarketingClient>> getStakeholders({
    int? typeId,
    String? search,
    int page = 1,
    int limit = 100,
  });
  Future<List<MarketingClient>> getStakeholdersByType(int typeId);
  Future<MarketingClient?> getStakeholderById(String id);
}

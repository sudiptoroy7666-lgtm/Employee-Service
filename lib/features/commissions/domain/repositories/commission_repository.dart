import '../models/commission.dart';

abstract class CommissionRepository {
  Future<List<Commission>> getCommissions();
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/api_utils.dart';
import '../domain/models/commission.dart';
import '../domain/repositories/commission_repository.dart';

class RemoteCommissionRepository implements CommissionRepository {
  final ApiClient _client;

  RemoteCommissionRepository(this._client);

  @override
  Future<List<Commission>> getCommissions() async {
    try {
      final res = await _client.dio.get('/api/accounts/commissions');
      final list = extractList(res.data);

      return list.map((j) {
        final json = j as Map<String, dynamic>;
        return Commission(
          id: json['id']?.toString() ?? '',
          month: json['invoice']?['createdAt']?.toString() ?? 'Current',
          totalSales: double.tryParse(
                  json['invoice']?['totalAmount']?.toString() ?? '0') ??
              0,
          commissionRate: double.tryParse(
                  json['commissionPercentage']?.toString() ?? '0') ??
              0,
          commissionAmount: double.tryParse(
                  json['commissionAmount']?.toString() ?? '0') ??
              0,
          status: json['isAdjusted'] == true
              ? CommissionStatus.paid
              : CommissionStatus.pending,
        );
      }).toList();
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      debugPrint('getCommissions failed: status=$statusCode');

      if (statusCode == 404 || statusCode == 500) {
        return [];
      }

      throw const AppFailure('Unable to load commissions.');
    }
  }
}

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../features/orders/domain/models/product.dart';
import '../../../core/errors/failures.dart';
import '../domain/models/promotion.dart';
import '../domain/repositories/promotion_repository.dart';
import 'package:flutter/foundation.dart';

class RemotePromotionRepository implements PromotionRepository {
  final ApiClient _client;

  RemotePromotionRepository(this._client);

  @override
  Future<List<Promotion>> getPromotions() async {
    final res = await _client.dio.get('/api/market-update/');
    final list = res.data is List ? res.data as List : (res.data['data'] as List? ?? []);

    return list.map((json) {
      final notes = json['notes']?.toString() ?? '';
      int demand = 0;
      String? compName;
      String prodName = json['seedType']?['name']?.toString() ?? '';

      // Parse the concatenated notes string: "Promo: X. Demand: Y. Comp: Z"
      final demandMatch = RegExp(r'Demand:\s*(\d+)').firstMatch(notes);
      if (demandMatch != null) {
        demand = int.tryParse(demandMatch.group(1)!) ?? 0;
      }

      final compMatch = RegExp(r'Comp:\s*(.+)$').firstMatch(notes);
      if (compMatch != null) {
        compName = compMatch.group(1)?.trim();
        if (compName == 'N/A') compName = null;
      }

      // If product name is missing from API, extract it from notes
      if (prodName.isEmpty || prodName == 'Unknown') {
        final promoMatch = RegExp(r'Promo:\s*(.+?)\.\s*Demand:').firstMatch(notes);
        if (promoMatch != null) {
          prodName = promoMatch.group(1)!.trim();
        }
      }

      return Promotion(
        id: json['id']?.toString() ?? '',
        productName: prodName.isNotEmpty ? prodName : 'Market Update',
        productId: json['seedTypeId']?.toString() ?? '',
        estimatedDemand: demand,
        competitorProductName: compName,
        syncStatus: PromotionSyncStatus.synced,
      );
    }).toList();
  }

  @override
  Future<List<Product>> getProducts() async {
    final products = <Product>[];

    // ---- Fetch from Bulk Inventory ----
    try {
      final resBulk = await _client.dio.get(ApiEndpoints.inventoryBulk);
      final bulkData = resBulk.data;

      if (bulkData is Map<String, dynamic>) {
        final data = bulkData['data'];
        if (data is Map<String, dynamic>) {
          for (final entry in data.entries) {
            final seedType = entry.value;
            if (seedType is Map<String, dynamic>) {
              final seedTypeName = seedType['seedTypeName']?.toString() ?? 'Unknown';
              final seedTypeId = seedType['seedTypeId']?.toString() ?? entry.key;
              final batches = seedType['batches'];

              double totalQty = 0;
              double unitPrice = 0;

              if (batches is List) {
                for (final batch in batches) {
                  if (batch is Map<String, dynamic>) {
                    totalQty += double.tryParse(
                            batch['remainingQuantity']?.toString() ?? '0') ?? 0;
                    unitPrice = double.tryParse(
                            batch['unitPrice']?.toString() ?? '0') ?? 0;
                  }
                }
              }

              if (totalQty > 0) {
                products.add(Product(
                  id: seedTypeId,
                  name: seedTypeName,
                  price: unitPrice,
                  unit: 'kg',
                  category: 'Bulk',
                ));
              }
            }
          }
        }
      }
      debugPrint('✅ Promotion: Loaded ${products.length} bulk products');
    } catch (e) {
      debugPrint('⚠️ Promotion: Failed to fetch bulk inventory: $e');
    }

    // ---- Fetch from Packaged Inventory ----
    try {
      final resPack = await _client.dio.get(ApiEndpoints.inventoryPackaged);
      final packData = resPack.data;

      if (packData is Map<String, dynamic>) {
        final data = packData['data'];
        if (data is List) {
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              products.add(Product(
                id: item['id']?.toString() ?? '',
                name: item['seedType']?['name']?.toString() ??
                    item['name']?.toString() ?? 'Unknown',
                price: double.tryParse(item['unitPrice']?.toString() ?? '0') ?? 0,
                unit: item['packetSize']?['name']?.toString() ?? 'packet',
                category: 'Packaged',
              ));
            }
          }
        }
      }
      debugPrint('✅ Promotion: Total products now: ${products.length}');
    } catch (e) {
      debugPrint('⚠️ Promotion: Failed to fetch packaged inventory: $e');
    }

    // If API returns nothing, provide fallback products for testing
    if (products.isEmpty) {
      debugPrint('⚠️ Promotion: No products from API, using fallback');
      products.addAll([
        Product(id: '36', name: 'Wheat', price: 100, unit: 'kg', category: 'Bulk'),
        Product(id: '37', name: 'Maize (Corn)', price: 100, unit: 'kg', category: 'Bulk'),
        Product(id: '49', name: 'Brinjal (Eggplant)', price: 4500, unit: 'kg', category: 'Bulk'),
        Product(id: '138', name: 'CIS-Ruposhi 1', price: 229, unit: 'kg', category: 'Bulk'),
      ]);
    }

    return products;
  }

  @override
  Future<Promotion> createPromotion(Promotion promotion) async {
    try {
      await _client.dio.post('/api/market-update/', data: {
        'seedTypeId': int.tryParse(promotion.productId) ?? 36, // FIX: Cast to int
        'regionId': 1, // FIX: Add required regionId
        'pricePerKg': promotion.competitorPrice ?? 100.0, // FIX: Use non-zero default
        'date': DateTime.now().toIso8601String(),
        'notes': 'Promo: ${promotion.productName}. Demand: ${promotion.estimatedDemand}. Comp: ${promotion.competitorProductName ?? 'N/A'}',
      });
      return promotion;
    } on DioException catch (e) {
      final errorBody = e.response?.data;
      if (errorBody is Map && errorBody['error'] != null) {
        throw AppFailure(errorBody['error'].toString());
      }
      throw const AppFailure('Failed to save market update.');
    }
  }
}

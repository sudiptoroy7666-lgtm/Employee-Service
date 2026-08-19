import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import 'package:flutter/foundation.dart';
import '../../../core/errors/failures.dart';
import '../domain/models/order.dart';
import '../domain/models/order_item.dart';
import '../domain/models/order_status.dart';
import '../domain/models/product.dart';
import '../domain/repositories/order_repository.dart';

class RemoteOrderRepository implements OrderRepository {
  final ApiClient _client;

  RemoteOrderRepository(this._client);

  @override
  Future<List<Order>> getOrders() async {
    try {
      final resBulk = await _client.dio.get('/api/sales/get-bulk-order');
      final resPack = await _client.dio.get('/api/sales/get-packaged-order');

      final List<dynamic> allOrders = [
        ...(resBulk.data is List ? resBulk.data as List : []),
        ...(resPack.data is List ? resPack.data as List : []),
      ];

      return allOrders.map((json) {
        // FIX 1: Properly parse the items array instead of hardcoding []
        final itemsList = (json['items'] as List? ?? []).map((itemJson) {
          final i = itemJson as Map<String, dynamic>;
          final productName = i['bulkInventory']?['seedType']?['value']?.toString() ??
              i['packagedInventory']?['seedType']?['value']?.toString() ??
              'Unknown Product';
          return OrderItem(
            id: i['id']?.toString() ?? '',
            productName: productName,
            quantity: int.tryParse(i['quantity']?.toString() ?? '0') ?? 0,
            unitPrice: double.tryParse(i['unitPrice']?.toString() ?? '0') ?? 0.0,
            totalPrice: double.tryParse(i['totalPrice']?.toString() ?? '0') ?? 0.0,
          );
        }).toList();

        return Order(
          id: json['id']?.toString() ?? '',
          orderNumber: json['saleId']?.toString() ?? json['invoiceNumber']?.toString() ?? '',
          clientId: json['stakeholderId']?.toString() ?? '',
          // FIX 2: Fallback to Client ID if the name isn't eagerly loaded by the API
          clientName: json['stakeholder']?['name']?.toString() ?? 'Client #${json['stakeholderId']}',
          orderDate: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
          deliveryDate: (DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now()).add(const Duration(days: 7)),
          status: OrderStatus.pending,
          totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0,
          items: itemsList, // Pass the parsed items
          supervisorName: json['createdBy']?['fullName']?.toString() ?? '', // Pass the supervisor name
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ getOrders failed: $e');
      return [];
    }
  }

  @override
  Future<Order?> getOrderById(String id) async {
    final orders = await getOrders();
    return orders.where((o) => o.id == id).firstOrNull;
  }

  @override
  Future<Order> createOrder(Order order) async {
    try {
      final subtotal = order.items.fold(0.0, (sum, i) => sum + i.totalPrice);

      final payload = {
        'stakeholderId': int.tryParse(order.clientId) ?? order.clientId,
        'discountType': 'flat',
        'discountValue': 0,
        'subtotal': subtotal,
        'totalAmount': subtotal,
        'paidAmount': 0,
        'paymentMethodId': 96, // Cash
        'items': order.items.map((i) => {
          // FIX: Send the Batch ID as bulkInventoryId, NOT the seedTypeId
          'bulkInventoryId': int.tryParse(i.id) ?? i.id,
          'quantity': i.quantity,
          'unitPrice': i.unitPrice,
          'totalPrice': i.totalPrice,
        }).toList(),
      };

      if (order.notes.isNotEmpty) payload['note'] = order.notes;

      debugPrint('📤 ORDER PAYLOAD: $payload');

      final res = await _client.dio.post('/api/sales/create-bulk-order', data: payload);
      debugPrint('✅ ORDER SUCCESS: ${res.data}');
      return order;
    } on DioException catch (e) {
      debugPrint('❌ ORDER FAILED: Status ${e.response?.statusCode}');
      debugPrint('❌ ORDER ERROR BODY: ${e.response?.data}');

      final errorBody = e.response?.data;
      if (errorBody is Map && errorBody['message'] != null) throw AppFailure(errorBody['message'].toString());
      if (errorBody is Map && errorBody['error'] != null) throw AppFailure(errorBody['error'].toString());
      throw AppFailure('Server Error: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<List<Product>> getProducts() async {
    final products = <Product>[];

    try {
      final resBulk = await _client.dio.get('/api/inventory/bulk');
      final bulkData = resBulk.data;

      if (bulkData is Map<String, dynamic>) {
        final data = bulkData['data'];

        if (data is Map<String, dynamic>) {
          for (final entry in data.entries) {
            final seedType = entry.value;
            if (seedType is Map<String, dynamic>) {
              final seedTypeName = seedType['seedTypeName']?.toString() ?? 'Unknown';
              final batches = seedType['batches'];

              double totalQty = 0;
              double unitPrice = 0;
              String? batchId; // FIX: Capture the actual Batch ID

              if (batches is List) {
                for (final batch in batches) {
                  if (batch is Map<String, dynamic>) {
                    // Get the ID of the inventory batch (e.g., 5), not the seed type (36)
                    batchId ??= batch['id']?.toString();

                    totalQty += double.tryParse(
                        batch['remainingQuantity']?.toString() ?? '0') ?? 0;
                    unitPrice = double.tryParse(
                        batch['unitPrice']?.toString() ?? '0') ?? 0;
                  }
                }
              }

              // FIX: Use the batchId as the product ID
              if (totalQty > 0 && batchId != null) {
                products.add(Product(
                  id: batchId,
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

      debugPrint('Loaded ${products.length} bulk products');
    } catch (e) {
      debugPrint('Failed to fetch bulk inventory: $e');
    }

    try {
      final resPack = await _client.dio.get('/api/inventory/packaged');
      final packData = resPack.data;

      if (packData is Map<String, dynamic>) {
        final data = packData['data'];

        if (data is List) {
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              products.add(Product(
                id: item['id']?.toString() ?? '',
                name: item['seedType']?['name']?.toString() ??
                    item['name']?.toString() ??
                    'Unknown',
                price: double.tryParse(item['unitPrice']?.toString() ?? '0') ?? 0,
                unit: item['packetSize']?['name']?.toString() ?? 'packet',
                category: 'Packaged',
              ));
            }
          }
        }
      }

      debugPrint('Loaded ${products.length} total products (bulk + packaged)');
    } catch (e) {
      debugPrint('Failed to fetch packaged inventory: $e');
    }

    return products;
  }
}
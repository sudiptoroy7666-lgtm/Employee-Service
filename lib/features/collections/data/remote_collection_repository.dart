import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/api_utils.dart';
import '../../../../core/errors/failures.dart';
import '../domain/models/collection.dart';
import '../domain/repositories/collection_repository.dart';

class RemoteCollectionRepository implements CollectionRepository {
  final ApiClient _client;

  RemoteCollectionRepository(this._client);

  @override
  Future<List<Collection>> getCollections() async {
    try {
      debugPrint('📡 Fetching ALL invoices from /api/sales/invoices...');
      final res = await _client.dio.get('/api/sales/invoices');

      final list = extractList(res.data);
      debugPrint('📊 Extracted ${list.length} invoices from response.');

      if (list.isEmpty) {
        return [];
      }

      return list.map((j) {
        final json = j as Map<String, dynamic>;

        final totalAmount = double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0;
        final paidAmount = double.tryParse(json['paidAmount']?.toString() ?? '0') ?? 0.0;
        final dueAmount = double.tryParse(json['dueAmount']?.toString() ?? '0') ?? (totalAmount - paidAmount);

        // FIX: Fallback for client name since the API might only return bulkSaleId
        String clientName = json['stakeholderName']?.toString() ??
            json['stakeholder']?['name']?.toString() ??
            json['bulkSale']?['stakeholder']?['name']?.toString() ??
            '';

        if (clientName.isEmpty && json['bulkSaleId'] != null) {
          clientName = 'Bulk Sale #${json['bulkSaleId']}';
        } else if (clientName.isEmpty && json['packagedSaleId'] != null) {
          clientName = 'Packaged Sale #${json['packagedSaleId']}';
        } else if (clientName.isEmpty) {
          clientName = 'Unknown Client';
        }

        return Collection(
          id: json['id']?.toString() ?? '', // Numeric DB ID (e.g., "3")
          invoiceId: json['invoiceId']?.toString() ?? json['id']?.toString() ?? '', // String ID (e.g., "INV-0003")
          clientName: clientName,
          amount: dueAmount,
          totalAmount: totalAmount,
          paidAmount: paidAmount,
          orderType: json['packagedSaleId'] != null ? 'packaged' : 'bulk',
          orderNumber: json['invoiceId']?.toString() ?? json['id']?.toString() ?? '',
          collectionDate: json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now(),
          paymentMethod: json['status']?['value']?.toString() ?? 'Pending',
          paymentMethodId: 0,
          referenceNumber: json['invoiceId']?.toString() ?? '',
          notes: '',
          imageUrls: const [],
          isLocalOnly: false,
          syncStatus: CollectionSyncStatus.synced,
        );
      }).toList(); // FIX: Removed the .where() filter so paid history shows up!
    } catch (e) {
      debugPrint('❌ getCollections CRASH: $e');
      return [];
    }
  }

  @override
  Future<Collection> createCollection(Collection collection) async {
    try {
      // FIX: Use the numeric database ID (collection.id) for the URL path,
      // as REST APIs usually expect the primary key (e.g., /3/), not the string "INV-0003".
      final endpoint = '${ApiEndpoints.recordPayment}/${collection.id}/record-payment';

      debugPrint('📤 Recording payment at: $endpoint');

      final res = await _client.dio.patch(
        endpoint,
        data: {
          'amount': collection.amount,
          'paymentMethodId': collection.paymentMethodId,
          'note': collection.notes,
          'imageUrls': collection.imageUrls,
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return collection.copyWith(
          syncStatus: CollectionSyncStatus.synced,
          isLocalOnly: false,
        );
      }

      throw const AppFailure('Failed to record payment.');
    } on DioException catch (e) {
      final errorBody = e.response?.data;
      debugPrint('❌ createCollection failed: ${e.response?.statusCode}, body: $errorBody');
      if (errorBody is Map && errorBody['error'] != null) {
        throw AppFailure(errorBody['error'].toString());
      }
      if (errorBody is Map && errorBody['message'] != null) {
        throw AppFailure(errorBody['message'].toString());
      }
      throw const AppFailure('Failed to record payment. Please try again.');
    }
  }

  @override
  Future<List<Collection>> getCollectionHistory({
    String? stakeholderId,
    int? statusId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (stakeholderId != null) queryParams['stakeholderId'] = stakeholderId;
    if (statusId != null) queryParams['statusId'] = statusId;

    final res = await _client.dio.get(
      ApiEndpoints.invoices,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final list = extractList(res.data);

    return list.map((j) {
      final json = j as Map<String, dynamic>;
      final totalAmount = double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0;
      final paidAmount = double.tryParse(json['paidAmount']?.toString() ?? '0') ?? 0.0;
      final dueAmount = double.tryParse(json['dueAmount']?.toString() ?? '0') ?? 0.0;

      String clientName = json['bulkSale']?['stakeholder']?['name']?.toString() ??
          json['posOrder']?['customerName']?.toString() ??
          '';

      if (clientName.isEmpty && json['bulkSaleId'] != null) {
        clientName = 'Bulk Sale #${json['bulkSaleId']}';
      } else if (clientName.isEmpty) {
        clientName = 'Unknown';
      }

      return Collection(
        id: json['id']?.toString() ?? '',
        invoiceId: json['invoiceId']?.toString() ?? '',
        clientName: clientName,
        amount: dueAmount,
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        orderType: json['packagedSaleId'] != null ? 'packaged' : 'bulk',
        orderNumber: json['invoiceId']?.toString() ?? json['bulkSale']?['saleId']?.toString() ?? '',
        collectionDate: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
        paymentMethod: json['status']?['value']?.toString() ?? 'Unknown',
        paymentMethodId: 0,
        referenceNumber: json['invoiceId']?.toString() ?? '',
        notes: '',
        imageUrls: const [],
        isLocalOnly: false,
        syncStatus: CollectionSyncStatus.synced,
      );
    }).toList();
  }
}
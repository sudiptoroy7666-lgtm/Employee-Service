import '../../../../core/network/api_client.dart';
import '../domain/models/product.dart';
import 'dto/inventory_dto.dart';

class RemoteProductRepository {
  final ApiClient _client;

  RemoteProductRepository(this._client);

  Future<List<Product>> getProducts() async {
    final resPackaged = await _client.dio.get('/api/inventory/packaged');
    final resBulk = await _client.dio.get('/api/inventory/bulk');

    final List<dynamic> allItems = [
      ...(resPackaged.data is List ? resPackaged.data as List : []),
      ...(resBulk.data is List ? resBulk.data as List : []),
    ];

    return allItems.map((j) {
      final dto = InventoryItemDto.fromJson(j as Map<String, dynamic>);
      return Product(
        id: dto.id,
        name: dto.name,
        price: dto.price,
        unit: dto.unit,
        category: dto.category,
      );
    }).toList();
  }
}

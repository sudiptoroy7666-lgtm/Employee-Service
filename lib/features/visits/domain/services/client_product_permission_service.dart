import '../../../orders/domain/models/product.dart';
import '../models/marketing_client.dart';

class ClientProductPermissionService {
  /// Filters products based on client permissions.
  ///
  /// If allowedProductIds is empty (not yet configured),
  /// ALL products are shown regardless of bulk permission.
  /// This prevents the dropdown from being empty.
  List<Product> filterAllowedProducts({
    required MarketingClient client,
    required List<Product> products,
  }) {
    // If no specific permissions are configured, show ALL products
    if (client.allowedProductIds.isEmpty) {
      return products; // Show everything - don't filter by bulk permission
    }

    // If specific permissions exist, filter by them
    return products.where((product) {
      final isAllowed = client.allowedProductIds.contains(product.id);
      return isAllowed;
    }).toList();
  }
}